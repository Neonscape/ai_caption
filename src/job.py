# file for the job queue and job worker.

from .types import RequestQueryResult, CaptionRequest, CaptionResult
from loguru import logger
from collections import deque
from typing import Optional
from apscheduler.schedulers.background import BackgroundScheduler
import uuid, asyncio, aiohttp, json
from .db import TaskService
from .utils import singleton


caption_prompt = """
请为这张图片生成RPG游戏中人物或物品的名字和描述，要求幽默诙谐，能让人会心一笑。
名字要求在2~10字之间，描述的字数在10~20字之间并且需要富有想象力。
请以JSON格式输出，格式如下：
{
    "title": "名字",
    "description": "描述"
}
注意：请只输出文案，不要输出其他无关内容。
"""
caption_model = "MiniCPM-V"

retry_times = 3
# times to try when server fails to provide a valid response.


@singleton
class JobQueue:
    """
    class for the job queue.
    """

    def __init__(self):
        self.queue: deque = deque()
        self.token_map: dict[str, CaptionRequest] = {}

    def add_job(self, request: CaptionRequest) -> str:
        """add a job to the queue, return it's token.

        Arguments:
            request -- the request to be queued

        Returns:
            request_token
        """
        self.queue.append(request)
        self.token_map[request.request_token] = request
        request.request_token = str(uuid.uuid4())
        return request.request_token

    def is_empty() -> bool:
        return len(self.queue) == 0

    def get_job(self) -> Optional[CaptionRequest]:
        """
        get a job from the queue, then pop it from queue.
        if queue is empty, return None.

        Returns:
            CaptionRequest
        """
        request = self.queue.popleft()
        if request is not None:
            return None

        self.token_map.pop(request.request_token)
        logger.info(f"popped job {request.request_token} from job queue")
        return request

    def get_job_status(self, request_token: str) -> RequestQueryResult:
        """
        get the status of a job.

        Arguments:
            request_token -- the token of the request

        Returns:
            finished -- if the job is finished or not.
            index -- the job's index in queue if it's not finished yet.
        """
        if request_token in self.token_map:
            return RequestQueryResult(
                False, self.queue.index(self.token_map[request_token])
            )
        else:
            return RequestQueryResult(True, 0)


@singleton
class JobWorker:
    def __init__(
        self, job_queue: JobQueue, caption_api_url: str, task_service: TaskService
    ):
        self.job_queue = job_queue
        self.scheduler = BackgroundScheduler()
        self.api_url = caption_api_url
        self.current_requests: list[Optional[CaptionRequest]] = []
        self.task_service: TaskService = task_service

    async def _process_job(self):
        """
        Obtain a job from the queue and process its caption.
        save the generated caption result to database.
        if generation failed for all retries, an empty result will be saved.
        """
        request = self.job_queue.get_job()
        if request is None:
            logger.info(f"No requests pending.")
            return

        self.current_requests.append(request)

        logger.info(f"processing request {request.request_token}...")
        data = {
            "model": caption_model,
            "prompt": caption_prompt,
            "images": [request.image],
            "stream": False,
            "format": "json",
        }

        times = 0
        caption_result: CaptionResult = None
        while times < retry_times:
            try:
                async with aiohttp.ClientSession() as session:
                    async with session.post(self.api_url, data) as resp:
                        resp_data: dict = (await resp.json())["response"]
                        if (
                            "title" not in resp_data.keys()
                            or "description" not in resp_data.keys()
                        ):
                            raise Exception("invalid response")
                        caption_result = CaptionResult(
                            request_token=request.request_token,
                            image=request.image,
                            title=resp_data["title"],
                            description=resp_data["description"],
                        )
                        break
            except Exception as e:
                logger.warning(
                    f"failed to get valid caption for request {request.request_token}"
                )
                logger.warning(f"ERROR: {e}, retrying... ({times}/{retry_times})")
                times += 1

        if caption_result is None:
            logger.error(f"all retries failed for request {request.request_token}")
            caption_result = CaptionResult(
                request_token=request.request_token,
                image=request.image,
                title="",
                description="",
            )

        self.task_service.add_request(
            request_token=request.request_token,
            user_token=request.user_token,
            img=request.img,
            title=caption_result.title,
            description=caption_result.description,
        )

        self.current_requests.remove(request)

    def process_job(self):
        """
        wrapper for the process function since apscheduler cannot run async functions directly.
        """
        logger.info("trying to process caption requests...")
        asyncio.run(self._process_job())

    def init_worker(self):
        """
        initialize the worker with a timed job.
        """
        self.scheduler.add_job(self.process_job, "interval", seconds=2, max_instances=1)
        pass
