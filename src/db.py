import sqlite3
import hashlib
import uuid
from loguru import logger

def singleton(cls):
    instances = {}
    def get_instance(*args, **kwargs):
        if cls not in instances:
            instances[cls] = cls(*args, **kwargs)
        return instances[cls]
    return get_instance

class Database:
    """
    Abstract class for database.
    """

    def __init__(self, db_path):
        try:
            self.conn = sqlite3.connect(db_path)
            self.cursor = self.conn.cursor()
            logger.info(f"Connected to database at {db_path}")
        except sqlite3.Error as e:
            logger.error(f"FATAL ERROR: Failed to connect to database: {e}")
            exit(1)

    def close(self):
        self.conn.close()
        logger.info("Database connection closed.")

@singleton
class UserDatabase(Database):
    """Database for user accounts."""

    def __init__(self, db_path="users.db"):
        super().__init__(db_path=db_path)

    def init_database(self):
        self.cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS users(
                username TEXT PRIMARY KEY,
                user_token TEXT NOT NULL UNIQUE,
                password TEXT NOT NULL
            )
            """
        )
        self.conn.commit()

@singleton
class RequestDatabase(Database):
    """Database for request history."""

    def __init__(self, db_path="requests.db"):
        super().__init__(db_path=db_path)

    def init_database(self):
        self.cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS requests(
                request_token TEXT PRIMARY KEY,
                user_token TEXT NOT NULL,
                img TEXT NOT NULL,
                title TEXT NOT NULL,
                description TEXT
            )
            """
        )
        self.conn.commit()

class AuthService:
    def __init__(self):
        self.user_db = UserDatabase()
        self.user_db.init_database()

    def hash_password(self, password):
        return hashlib.sha256(password.encode('utf-8')).hexdigest()

    def register(self, username, password):
        # 检查重名
        self.user_db.cursor.execute("SELECT * FROM users WHERE username = ?", (username,))
        if self.user_db.cursor.fetchone():
            logger.warning(f"Registration failed: Username '{username}' already exists.")
            return {"success": False, "message": "Username already exists."}

        # 生成编号
        user_token = str(uuid.uuid4())

        # 密码哈希
        hashed_password = self.hash_password(password)
        
        try:
            self.user_db.cursor.execute(
                "INSERT INTO users (username, user_token, password) VALUES (?, ?, ?)",
                (username, user_token, hashed_password)
            )
            self.user_db.conn.commit()
            logger.info(f"User '{username}' registered successfully.")
            return {"success": True, "user_token": user_token}
        except sqlite3.Error as e:
            logger.error(f"Registration failed: {e}")
            return {"success": False, "message": "Registration failed due to a database error."}

    def login(self, username, password):
        self.user_db.cursor.execute("SELECT user_token, password FROM users WHERE username = ?", (username,))
        result = self.user_db.cursor.fetchone()
        if not result:
            logger.warning(f"Login failed: Username '{username}' does not exist.")
            return {"success": False, "message": "Username does not exist."}

        user_token, stored_password = result
        hashed_password = self.hash_password(password)

        if hashed_password == stored_password:
            logger.info(f"User '{username}' logged in successfully.")
            return {"success": True, "user_token": user_token}
        else:
            logger.warning(f"Login failed: Incorrect password for username '{username}'.")
            return {"success": False, "message": "Incorrect password."}

    def change_password(self, user_token, old_password, new_password):
        """
        修改用户密码。

        参数:
            user_token (str): 用户的唯一标识符。
            old_password (str): 用户当前的密码。
            new_password (str): 用户希望设置的新密码。

        返回:
            dict: 操作结果，包含成功状态和消息。
        """
        # 查询用户的当前密码
        self.user_db.cursor.execute("SELECT password FROM users WHERE user_token = ?", (user_token,))
        result = self.user_db.cursor.fetchone()
        if not result:
            logger.warning(f"Change password failed: Invalid user_token '{user_token}'.")
            return {"success": False, "message": "Invalid user token."}

        stored_password = result[0]
        hashed_old_password = self.hash_password(old_password)

        if hashed_old_password != stored_password:
            logger.warning(f"Change password failed: Incorrect old password for user_token '{user_token}'.")
            return {"success": False, "message": "Incorrect old password."}

        # 哈希新密码
        hashed_new_password = self.hash_password(new_password)

        # 更新密码
        try:
            self.user_db.cursor.execute(
                "UPDATE users SET password = ? WHERE user_token = ?",
                (hashed_new_password, user_token)
            )
            self.user_db.conn.commit()
            logger.info(f"Password changed successfully for user_token '{user_token}'.")
            return {"success": True, "message": "Password changed successfully."}
        except sqlite3.Error as e:
            logger.error(f"Change password failed: {e}")
            return {"success": False, "message": "Failed to change password due to a database error."}

class TaskService:
    def __init__(self):
        self.request_db = RequestDatabase()
        self.request_db.init_database()

    def add_request(self, user_token, img, title, description):
        request_token = str(uuid.uuid4())
        try:
            self.request_db.cursor.execute(
                "INSERT INTO requests (request_token, user_token, img, title, description) VALUES (?, ?, ?, ?, ?)",
                (request_token, user_token, img, title, description)
            )
            self.request_db.conn.commit()
            logger.info(f"Request '{request_token}' added for user '{user_token}'.")
            return {"success": True, "request_token": request_token}
        except sqlite3.Error as e:
            logger.error(f"Failed to add request: {e}")
            return {"success": False, "message": "Failed to add request due to a database error."}

    def get_history(self, user_token):
        try:
            self.request_db.cursor.execute(
                "SELECT request_token, img, title, description FROM requests WHERE user_token = ?",
                (user_token,)
            )
            rows = self.request_db.cursor.fetchall()
            history = []
            for row in rows:
                history.append({
                    "request_token": row[0],
                    "img": row[1],
                    "title": row[2],
                    "description": row[3]
                })
            logger.info(f"Retrieved history for user '{user_token}'.")
            return {"success": True, "history": history}
        except sqlite3.Error as e:
            logger.error(f"Failed to retrieve history: {e}")
            return {"success": False, "message": "Failed to retrieve history due to a database error."}
