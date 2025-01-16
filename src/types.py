# file for custom types, such as user, request, ...

from pydantic import BaseModel, Field, ValidationError


class User(BaseModel):
    """
    Class for User data type.

    Attributes:
        **user_token**: global identifier; unique for each user. This is the primary key for user table.
        username: custom display name for user
        password: user password
    """

    username: str = Field(..., description="User name")
    password: str = Field(..., description="User password")
    # TODO: more fields like avatar, gender, etc.
    # TODO: should we implement request rate limit?


class ChangeUsernameRequest(BaseModel):
    """
    Class for changing username request.

    Attributes:
        **user_token**: global identifier; unique for each user. This is the primary key for user table.
        new_username: new username for user
    """

    user_token: str
    new_username: str


class ChangePasswordRequest(BaseModel):
    """
    Class for changing password request.

    Attributes:
        **user_token**: global identifier; unique for each user. This is the primary key for user table.
        old_password: old password for user
        new_password: new password for user
    """

    user_token: str
    old_password: str
    new_password: str


class HistoryRequest(BaseMOdel):
    """
    Class for history requests.

    Attributes:
        **user_token**: the user to look history for.
    """

    user_token: str


class CaptionRequest(BaseModel):
    """
    Class for a caption request.
    this is only for internal representation within backend;
    API should be used for client call.

    Attributes:
        **request_token**: global identifier; unique for each request (in request queue).
        user_token: user token for user who made the request; used for authentication.
        image: the image to be captioned; base64 encoded image string.
    """

    request_token: str
    user_token: str
    image: str


class GenerateRequest(BaseModel):
    """
    class for /generate requests. This is the API request.

    Attributes:
        **user_token**: the user who sent the request.
        image: the image to be captioned; base64 encoded image string.
    """

    user_token: str
    image: str


class StatusRequest(BaseModel):
    """
    class for /status requests. This is the API request.

    Attributes:
        **request_token**: the request token to query.
    """

    request_token: str


class RequestQueryResult(BaseModel):
    """
    class for a caption query result.
    that is, when using /request_status to query the status of a request,
    return instances of this class.

    Attributes:
        finished: if the request is finished.
        index: how many requests are in queue before this request.
    """

    finished: bool
    index: int


class CaptionResult(BaseModel):
    """
    Class for a caption result.

    Attributes:
        **request_token**: global identifier; unique for each request (in request queue).
        image: the image captioned; base64 encoded image string.
        title: the title for the image.
        description: the description for the image.
    """

    request_token: str
    image: str
    title: str
    description: str
