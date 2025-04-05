from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import inspect
class WebHandler(object):
    def __init__(self, host, port, logger, setup_fastapi_flag=False):
        """
        Initializes the FastAPI server with optional logger and CORS settings.

        :param host: The IP address to host the FastAPI server.
        :param port: The port to bind the FastAPI server.
        :param logger: Optional logger object for logging.
        """
        self.ip = host
        self.port = port
        self.logger = logger
        print("Logger file is : ", logger)
        self.logger.info("Logger created in web handler")
        self.app = FastAPI()
        self._setup_cors()
        self._setup_routes()
        self.logger.info("how are you?")
        if setup_fastapi_flag:
            self.start_handler()

        # if setup_fastapi_flag:
            # self.start_handler("main:web_handler.app")


    def _setup_cors(self):
        """
        Configures CORS middleware for the FastAPI app.
        """
        origins = [
            "http://localhost.tiangolo.com",
            "https://localhost.tiangolo.com",
            "http://localhost",
            f"http://{self.ip}:{self.port}",
        ]

        self.app.add_middleware(
            CORSMiddleware,
            allow_origins=["*"],
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )

    def _setup_routes(self):
        """
        Sets up all the routes dynamically by detecting methods like GET, POST, OPTIONS.
        """
        all_methods = self.get_all_apis()
        self.logger.info(f"All methods declared in main file are {all_methods}")
        for method_name, method_func in all_methods.items():
            if method_name.startswith("GET_"):
                route_path = method_name[4:]  # Extract the route name (e.g., from GET_api_name -> api_name)
                self.app.get(f"/{route_path}")(method_func)
            elif method_name.startswith("POST_"):
                route_path = method_name[5:]
                self.app.post(f"/{route_path}")(method_func)
            elif method_name.startswith("OPTIONS_"):
                route_path = method_name[8:]
                self.app.options(f"/{route_path}")(method_func)
                
    @staticmethod
    def execute(command=None, callback=None, _=None, **kwargs):
        """
        Example method to handle command execution. Replace with actual logic.
        """
        # This can be used to execute some command logic and return the result.
        return {"command": command, "callback": callback, "kwargs": kwargs}

    def get_all_apis(self):
        """
        Retrieves all methods starting with GET_, POST_, or OPTIONS_.
        """
        all_functions = inspect.getmembers(self, inspect.ismethod)
        response = {}
        for func_name, func in all_functions:
            if func_name.startswith(("GET_", "POST_", "OPTIONS_")):
                response[func_name] = func
        return response

    def is_api_exists(self, api_name: str) -> bool:
        """
        Checks if an API exists in the registered routes.
        """
        return api_name in self.all_server_apis

    def start_handler(self):
        """
        Starts the FastAPI server using uvicorn with auto-reload enabled.
        """
        if self.logger:
            self.logger.info("Starting FASTAPI server with auto-reload")

        print("Starting FASTAPI server with auto-reload")
        self.logger.info("Starting the server with auto-reload")

        # Pass the FastAPI app instance as the first argument
        uvicorn.run(self.app, host=self.ip, port=self.port)

        self.logger.info("Started the server with auto-reload")



    def stop_handler(self):
        """
        Stops the FastAPI server. FastAPI itself doesn't have a direct stop method,
        so this method is mostly a placeholder unless you handle uvicorn externally.
        """
        if self.logger:
            self.logger.info("Stopping FASTAPI server")
        print("Stopping FASTAPI server")
        self.logger.info("Stopping the server")


# if __name__ == '__main__':
#     # Assuming you have a logger instance
#     logger = setup_logger('server.log')  # Replace with your actual logger instance
#     web_handler = WebHandler('0.0.0.0', 8000, logger, True)
