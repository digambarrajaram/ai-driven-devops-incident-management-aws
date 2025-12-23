
# -------- Build stage --------
FROM python:3.10-slim AS builder

WORKDIR /build

COPY app/app.py .

RUN pip install --no-cache-dir flask

# -------- Runtime stage --------
FROM python:3.10-slim

WORKDIR /app

COPY --from=builder /usr/local/lib/python3.10 /usr/local/lib/python3.10
COPY --from=builder /usr/local/bin /usr/local/bin
COPY app/app.py .

EXPOSE 8080

CMD ["python", "app.py"]
