import logging
import watchtower
import boto3
import os

LOG_GROUP = os.getenv("LOG_GROUP_NAME", "geojson-processor-logs")

def get_logger():
    logger = logging.getLogger("geojson")
    logger.setLevel(logging.INFO)

    if not logger.handlers:
        logger.addHandler(
            watchtower.CloudWatchLogHandler(
                boto3_session=boto3.Session(),
                log_group=LOG_GROUP
            )
        )
    return logger
