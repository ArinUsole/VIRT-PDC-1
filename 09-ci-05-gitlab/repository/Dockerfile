FROM python:3.8
WORKDIR /python_api
ADD python-api.py .
RUN pip install flask flask-jsonpify flask-restful
CMD [ "python", "/python_api/python-api.py" ]