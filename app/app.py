from flask import Flask
import time
import random

app = Flask(__name__)

@app.route("/")
def home():
    return "AutoOpsAI Web App is running!"

@app.route("/stress")
def stress():
    while True:
        pass  # intentional CPU spike

@app.route("/error")
def error():
    return 1 / 0  # intentional error

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
