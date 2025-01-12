from pydantic import BaseModel, Field, ValidationError


class User(BaseModel):
    """
    Class for User data type.

    Attributes:
        **user_token**: global identifier; unique for each user. This is the primary key for user table.
        username: custom display name for user
        password: user password
    """

    user_token: str = Field(..., description="User token")
    username: str = Field(..., description="User name")
    password: str = Field(..., description="User password")
    # TODO: more fields like avatar, gender, etc.
    # TODO: should we implement request rate limit?


class CaptionRequest(BaseModel):
    """
    Class for a caption request.
    this is only for internal representation within backend;
    API should be used for client call.

    Attributes:
        **request_token**: global identifier; unique for each request (in request queue).
        user_token: user token for user who made the request; used for authentication.
        image: the image to be captioned; base64 encoded image string.
        finished: is the request finished or not
        data: if the request is not finished, this field is empty;
            if the request is finished, this field contains the result of the request.
    """

    request_token: str
    user_token: str
    image: str
    finished: bool = False
    title: str
    desc: str
