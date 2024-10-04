FROM python:3.9-slim

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade -r requirements.txt

WORKDIR /app

COPY main.py .

CMD ["sh","-c","python main.py"]
