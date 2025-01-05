FROM public.ecr.aws/lambda/python:3.9

COPY main.py .
COPY requirements.txt .
COPY lambda_function.py .

RUN pip install -r requirements.txt

CMD ["main.handler"]
