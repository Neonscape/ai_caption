import sqlite3, hashlib, uuid
from loguru import logger


class Database:
    """
    abstract class for database.
    """

    def __init__(self, db_path):
        try:
            self.conn = sqlite3.connect(db_path)
            self.cursor = self.conn.cursor()
        except sqlite3.Error as e:
            logger.error(f"FATAL ERROR: failed to connect to database: {e}")
            exit(1)

    def close():
        self.conn.close()


@singleton
class UserDatabase(Database):
    """database for user accounts.

    Arguments:
        Database -- _description_
    """

    def __init__(self, db_path):
        super().__init__(db_path="users.db")

    def init_database(self):
        self.cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS users(
                username TEXT PRIMARY KEY,
                user_token TEXT NOT NULL UNIQUE,
                password TEXT NOT NULL,
            )
            """
        )
        self.conn.commit()


@singleton
class RequestDatabase(Database):
    """database for request history.

    Arguments:
        Database -- _description_
    """

    def __init__(self, db_path):
        super().__init__(db_path="requests.db")

    def init_database(self):
        self.cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS requests(
                request_token TEXT PRIMARY KEY,
                user_token TEXT NOT NULL,
                img TEXT NOT NULL,
                title TEXT NOT NULL,
                desc TEXT
            )
            """
        )
        self.conn.commit()
