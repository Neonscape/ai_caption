from fastapi import FastAPI
from loguru import logger
import base64
from contextlib import asynccontextmanager
from .job import JobQueue, JobWorker
from .types import CaptionRequest
from .db import TaskService, AuthService, RequestDatabase
from .utils import singleton

request_db: RequestDatabase = None
jobqueue: JobQueue = None
jobworker: JobWorker = None
task_service: TaskService = None
auth_service: AuthService = None

caption_api_url = "http://192.168.3.27:11434/api/generate"


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    the function to run startup and shutdown tasks for the app.

    for startup jobs, put code before `yield`;
    for shutdown jobs, put code after `yield`.
    """

    # initialize database and jobqueue

    request_db = RequestDatabase()
    request_db.init_database()
    task_service = TaskService()
    auth_service = AuthService()
    jobqueue = JobQueue()
    jobworker = JobWorker(
        job_queue=jobqueue, caption_api_url=caption_api_url, task_service=task_service
    )
    jobworker.init_worker()
    yield

    # shutdown tasks...
    pass


app = FastAPI(lifespan=lifespan)


# NOTE: if your handler function depend on other async functions (await ..., aiohttp, ...)
#       then it must be defined as async as well (async def xxx...)
# ! PLEASE USE LOGURU'S LOGGER FOR DETAILED LOGGING!
# e.g. logger.info("this is an info")


@app.post("/register")
def register_user(username: str, password: str):
    return auth_service.register(username=username, password=password)


@app.post("/login")
def login_user(username: str, password: str):
    return auth_service.login(username=username, password=password)


@app.post("/change_username")
def change_username(user_token: str, new_username: str):
    return auth_service.change_username(
        user_token=user_token, new_username=new_username
    )


@app.post("/change_password")
def change_password(user_token: str, old_password: str, new_password: str):
    return auth_service.change_password(
        user_token=user_token, old_password=old_password, new_password=new_password
    )


@app.post("/history")
async def get_history(user_token: str):
    unfinished_jobs = jobworker.current_requests + [
        task for task in jobqueue.queue if task.user_token == user_token
    ]
    unfinished_history = [
        {
            "status": False,
            "request_token": task.request_token,
            "image": task.image,
            "title": "",
            "description": "",
        }
        for task in unfinished_jobs
    ]
    finished_jobs = task_service.get_history(user_token=user_token)
    finished_history = [
        {
            "status": True,
            "request_token": task["request_token"],
            "image": task["image"],
            "title": task["title"],
            "description": task["description"],
        }
        for task in finished_jobs
    ]
    return unfinished_history + finished_history


@app.post("/generate")
def generate_task(user_token: str, image: str):
    """
    perform input checks;
    if checks passed then create a new task in the task queue.

    Arguments:
        user_token -- user's token. used for authentication.
        image -- base64 encoded image; the image to be captioned.

    Returns:
        request_token -- the identifier for the request.
        error_msg -- error message if any.

    """

    # check if image is valid base64 string
    try:
        base64.b64decode(image)
    except Exception as e:
        logger.warning(f"invalid base64 encoding: {image}")
        return {"request_token": None, "error_msg": "invalid base64 encoding"}

    if not auth_service.verify_user_token(user_token=user_token):
        return {"request_token": "", "error_msg": "Invalid user token! Please relogin."}

    # add job to job queue
    if jobqueue is None:
        logger.error("JOB QUEUE IS NOT INITIALIZED!")
        exit(1)

    request: CaptionRequest = CaptionRequest(
        request_token="", user_token=user_token, image=image
    )
    request_token = jobqueue.add_job(request=request)
    return {"request_token": request_token, "error_msg": None}


@app.post("/request_status")
def request_status(request_token: str):
    if jobqueue is None:
        logger.error("JOB QUEUE IS NOT INITIALIZED!")
        exit(1)
    status = jobqueue.get_job_status(request_token=request_token)
    if status.finished:
        generating_tasks = [
            task
            for task in jobworker.current_requests
            if task.request_token == request_token
        ]
        if len(generating_tasks) > 0:
            status.finished = False
    return status.dict()
