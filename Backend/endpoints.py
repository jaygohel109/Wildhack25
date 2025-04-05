from utils.web_command_handler import WebHandler
from utils.logging_module import setup_logger

class Endpoints(WebHandler):
    def __init__(self, host, port, logger, fastapi_flag):
        self.host = host
        self.port = port
        self.logger = logger
        self.fastapi_flag = fastapi_flag
        super().__init__(self.host, self.port, self.logger, self.fastapi_flag)
    
    def GET_world(self):
        return {"value: ": "Hello World"}

if __name__ == "__main__":
    logger = setup_logger('endpoints.log')
    endpoint = Endpoints("0.0.0.0", 8000, logger, True)