FROM geerlingguy/docker-ubuntu1604-ansible

RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' >> /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add
RUN apt-get update
RUN apt-get install -y vim sshpass postgresql-10 libpq-dev python-psycopg2
RUN pip install --upgrade pip
RUN pip install psycopg2 boto boto3

RUN mkdir /ansible
WORKDIR /ansible

RUN echo 'export PS1="[\[\033[32m\]\w]\[\033[0m\]\n\[\033[1;36m\]\u\[\033[1;33m\]-> \[\033[0m\]"' >> /root/.bashrc
RUN echo 'alias cls=clear' >> /root/.bashrc
