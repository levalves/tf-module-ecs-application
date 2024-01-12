FROM python:3.8-slim
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY src/app.py app/
EXPOSE 8080

# Default command
CMD ["python", "app/app.py"]
