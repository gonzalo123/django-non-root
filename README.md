## Running Python/Django docker containers with non root user

Running linux processes as root is not a good idea. One problem or exploit with the process can give to the attacker a root shell. When we run one docker container, especially if this container is in production it shouldn't be run as root.

To do that we only need to generate a Dockerfile to properly run our Python/Django application as non root. That's my boilerplate:

```dockerfile
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
```

Also, in a Django application, we normally use a nginx as a reverse proxy. Nginx normally runs as root at it launches its procress as non root, but we also can run nginx as non root.

```dockerfile
FROM nginx:1.17.4

RUN rm /etc/nginx/conf.d/default.conf
RUN rm /etc/nginx/nginx.conf
COPY nginx.conf /etc/nginx/conf.d
COPY etc/nginx.conf /etc/nginx/nginx.conf

RUN chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d && \
    chmod -R 766 /var/log/nginx/

RUN touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid && \
    chown -R nginx:nginx /var/cache/nginx

USER nginx
```

