from utils.web_command_handler import WebHandler
from utils.logging_module import setup_logger
from fastapi import Request
from utils.database.model import SignupRequest, LoginRequest, ProfileCreate, ForgotPasswordRequest
from utils.database.database import signup_user, login_user, create_user_profile, forgot_password

class Endpoints(WebHandler):
    def __init__(self, host, port, logger, fastapi_flag):
        self.host = host
        self.port = port
        self.logger = logger
        self.fastapi_flag = fastapi_flag
        super().__init__(self.host, self.port, self.logger, self.fastapi_flag)
    
    def GET_world(self):
        return {"value: ": "Hello World"}  
    
    async def POST_signup(self, data: SignupRequest):
        try:

            self.logger.info(f"Signup attempt for: {data.username}")
            result = await signup_user(data.username, data.password, data.role)

            return result
        
        except Exception as e:
            self.logger.error(f"Error in signup: {str(e)}")
            return {"error": "Failed to create user", "detail": str(e)}


    async def POST_signin(self, data: LoginRequest):
            try:

                self.logger.info(f"Login attempt for: {data.username}")
                result = await login_user(data.username, data.password)

                return result
            
            except Exception as e:
                self.logger.error(f"Error in signin: {str(e)}")
                return {"error": "Failed to sign in", "detail": str(e)}
            
    async def POST_create_profile(self, profile: ProfileCreate):
        try:

            self.logger.info(f"Creating profile for user: {profile.user_id}, role: {profile.role}")
            result = await create_user_profile(profile)

            return result
        
        except Exception as e:
            self.logger.error(f"Error creating profile: {str(e)}")
            return {"error": "Profile creation failed", "detail": str(e)}
    
    async def POST_forgot_password(self, data: ForgotPasswordRequest):
        try:
            self.logger.info(f"Setting up new password for user: {data.username}")
            result = await forgot_password(data.username, data.new_password)
            return result
        except Exception as e:
            self.logger.error(f"Error in forgot passowrd")

if __name__ == "__main__":
    logger = setup_logger('endpoints.log')
    endpoint = Endpoints("0.0.0.0", 8000, logger, True)