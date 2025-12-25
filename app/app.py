from flask import Flask
import time
import random
import os
import logging

app = Flask(__name__)

# Basic logger setup (CloudWatch-friendly)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.route("/")
def home():
    if os.getenv("FAIL_MODE") == "true":
        logger.error("FAIL_MODE enabled: intentional failure for incident testing")
        raise Exception("Intentional failure")

    return "AutoOpsAI Web App is running!"

@app.route("/stress")
def stress():
    logger.warning("CPU stress endpoint triggered")
    start = time.time()
    while time.time() - start < 10:  # limit stress to 10 seconds
        pass
    return "CPU stress test completed"

@app.route("/error")
def error():
    logger.error("Intentional division-by-zero error triggered")
    return str(1 / 0)  # intentional error

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
