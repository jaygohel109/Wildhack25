import logging
import os
import json
from logging.handlers import RotatingFileHandler

current_directory = os.getcwd()
print("Current directory for logging module is: ", current_directory)

# Path for storing the mapping list
mapping_list_path = os.path.join(current_directory, "mapping-list", "mapping_list.json")

def create_log_file(file_name, logging_level="DEBUG", rotating_max_bytes=1024000, rotating_backup_count=100):
    '''
    Create a log file with RotatingFileHandler.

    :param file_name: Name of the log file.
    :param logging_level: The logging level (DEBUG, INFO, etc.).
    :param rotating_max_bytes: Max size for log file before rotation occurs.
    :param rotating_backup_count: Number of backup files to keep.
    '''
    log_file_path = os.path.join(current_directory, "logs", file_name)
    if not os.path.exists(os.path.dirname(log_file_path)):
        os.makedirs(os.path.dirname(log_file_path))

    logger = logging.getLogger(file_name)

    # Remove any existing handlers to ensure a clean setup
    logger.handlers.clear()

    # Set the logging level
    logger.setLevel(getattr(logging, logging_level.upper()))

    # Create and add a file handler (RotatingFileHandler)
    handler = RotatingFileHandler(
        log_file_path, maxBytes=rotating_max_bytes, backupCount=rotating_backup_count
    )
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    handler.setFormatter(formatter)
    logger.addHandler(handler)

    # Remove any StreamHandler (terminal output) from the root logger to suppress terminal logging
    for handler in logging.getLogger().handlers:
        if isinstance(handler, logging.StreamHandler):
            logging.getLogger().removeHandler(handler)
    # Set root logger level as well to ensure consistent logging
    logging.getLogger().setLevel(getattr(logging, logging_level.upper()))

    return logger


def get_mapping_list():
    '''
    Create a file for storing the name of loggers that have been configured.

    If file exists, load the list from file and simply return the list.
    Otherwise create a file and return empty list.

    :return: Dictionary containing loggers' name.
    '''
    mapping_list_dir = os.path.join(current_directory, "mapping-list")
    if not os.path.exists(mapping_list_dir):
        os.makedirs(mapping_list_dir)

    if not os.path.isfile(mapping_list_path):
        print('**** Creating mapping dictionary ****')
        with open(mapping_list_path, 'w') as file:
            json.dump({}, file)  # Initialize empty dict
        return {}  # Return the empty dictionary
    else:
        print("-----Loading the mapping dictionary---------")
        try:
            with open(mapping_list_path, 'r') as file:
                return json.load(file)
        except Exception as e:
            print(f"Error in loading the mapping dictionary: {e}")
            return {}


def update_mapping_list(mapping_dict):
    '''
    Update the mapping dictionary in the file.

    :param mapping_dict: Dictionary to save.
    '''
    print("-----Updating the mapping dictionary---------")
    try:
        with open(mapping_list_path, 'w') as file:
            json.dump(mapping_dict, file, indent=4)
    except Exception as e:
        print(f"Error in updating the mapping dictionary: {e}")
        raise


def check_handler(logger_name):
    '''
    Check if a logger already has a handler.
    
    :param logger_name: The logger's name to check.
    :return: True if handler exists, False otherwise.
    '''
    logger = logging.getLogger(logger_name)
    return len(logger.handlers) > 0


def setup_logger(logger_name, logging_level="DEBUG"):
    '''
    Set up a logger and update the mapping list.
    
    :param logger_name: The name of the logger.
    :param logging_level: The logging level (DEBUG, INFO, etc.).
    '''
    mapping_list = get_mapping_list()

    # If logger exists in mapping, remove its handlers to ensure a clean setup
    if logger_name in mapping_list:
        logger = logging.getLogger(logger_name)
        logger.handlers.clear()

    # Create new logger
    logger = create_log_file(logger_name, logging_level)

    # Update mapping list with the new logger
    mapping_list[logger_name] = logging_level
    update_mapping_list(mapping_list)

    print(f"Logger '{logger_name}' has been set up.")
    return logger