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

ARG TOWER_HOST=http://127.0.0.1:8052
ARG TOWER_USERNAME=admin
ARG TOWER_PASSWORD=awxpass
ARG TOWER_VERIFY_SSL=False
RUN pip install ansible-tower-cli
RUN tower-cli config host ${TOWER_HOST}
RUN tower-cli config username ${TOWER_USERNAME}
RUN tower-cli config password ${TOWER_PASSWORD}
RUN tower-cli config verify_ssl ${TOWER_VERIFY_SSL}
