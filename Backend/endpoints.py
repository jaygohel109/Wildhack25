from utils.web_command_handler import WebHandler
from utils.logging_module import setup_logger
from fastapi import Request
from utils.database.model import SignupRequest, LoginRequest, ProfileCreate, ForgotPasswordRequest
from utils.database.database import signup_user, login_user, create_user_profile, forgot_password, create_task, assign_task_to_volunteer, get_task_with_volunteer, get_matching_tasks, complete_task
from utils.database.tasks_model import TasksRequest, AssignTasks
from fastapi import Query

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
            return {"error": "Unable to reset the password"}

    async def POST_create_task(self, data: TasksRequest):
        try:
            result = await create_task(data)
            return result
        except Exception as e:
            self.logger.error("Error in creating the task")
            return {"error": "Unable to create the task"}
            
    async def POST_assign_task(self, data: AssignTasks):
        try:
            self.logger.info(f"Assigning task {data.task_id} to volunteer {data.volunteer_id}")
            result = await assign_task_to_volunteer(data.task_id, data.volunteer_id)
            return result
        except Exception as e:
            self.logger.error(f"Error assigning task: {str(e)}")
            return {"error": "Unable to assign task", "detail": str(e)}
    
    async def GET_matching_tasks(self,volunteer_id: str):
        try:
            result = await get_matching_tasks(volunteer_id)
            return result
        except Exception as e:
            self.logger.error(f"Error matching tasks")
            return {"error": "No tasks"}
        
    async def GET_task_with_volunteer(self, task_id:str):
        try:
            result = await get_task_with_volunteer(task_id)
            return result
        except Exception as e:
            self.logger.error(f"Error fetching task and volunteer info: {str(e)}")
            return {"error": "Unable to retrieve task details"}

    async def POST_complete_task(self, task_id: str):
        try:
            result = await complete_task(task_id)
            return result
        except Exception as e:
            self.logger.error(f"Unable to change the status to complete in task: {e}")
            return {"error": "Unable to change the status to complete in task"}
if __name__ == "__main__":
    logger = setup_logger('endpoints.log')
    endpoint = Endpoints("0.0.0.0", 8000, logger, True)