FROM python:3.11
WORKDIR /buzz-talk-api
COPY . /buzz-talk-api/
RUN pip install --upgrade pip
RUN pip3 install -r ./requirements.txt

EXPOSE 8000

CMD sh -c "chmod 600 /buzz-talk-api/.ssh/cpanel_username && python manage.py start_db_tunnel && python manage.py runserver 0.0.0.0:8000"