FROM python:3.8 AS base

ENV APP_HOME=/src
ENV APP_USER=appuser

RUN groupadd -r $APP_USER && \
    useradd -r -g $APP_USER -d $APP_HOME -s /sbin/nologin -c "Docker image user" $APP_USER

WORKDIR $APP_HOME

ENV TZ 'Europe/Madrid'
RUN echo $TZ > /etc/timezone && apt-get update && \
    apt-get install -y tzdata && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean

RUN pip install --upgrade pip

FROM base

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

COPY requirements.txt .
RUN pip install -r requirements.txt

ADD src .

RUN chown -R $APP_USER:$APP_USER $APP_HOME
USER $APP_USER
