from fastapi import FastAPI
from loguru import logger
import base64
from contextlib import asynccontextmanager
from .job import JobQueue, JobWorker
from .types import CaptionRequest

jobqueue: JobQueue = None

jobworker: JobWorker = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    the function to run startup and shutdown tasks for the app.

    for startup jobs, put code before `yield`;
    for shutdown jobs, put code after `yield`.
    """

    # initialize database and jobqueue

    jobqueue = JobQueue()
    jobworker = JobWorker(jobqueue=jobqueue)
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
def register_user():
    pass


@app.post("/login")
def login_user():
    pass


@app.post("/history")
async def get_history():
    pass


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

    # TODO: check user_token, depends on database implementation

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
    return status.dict()
