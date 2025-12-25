import os
import json
import logging
import time
import random

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler(event, context):
    """
    AutoOps Lambda Handler

    Controlled via environment variable FAIL_MODE.
    Used for intentional incident simulation and rollback testing.
    """

    fail_mode = os.getenv("FAIL_MODE", "false").lower()

    logger.info(f"Request received | FAIL_MODE={fail_mode}")

    # ---------------------------
    # Intentional Failure Path
    # ---------------------------
    if fail_mode == "true":
        logger.error("Intentional failure injected for incident testing")
        raise Exception("Injected failure via FAIL_MODE")

    # ---------------------------
    # Normal Healthy Response
    # ---------------------------
    response = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "service": "autoops-lambda",
            "status": "healthy",
            "request_id": context.aws_request_id
        })
    }

    logger.info("Healthy response returned")
    return response
