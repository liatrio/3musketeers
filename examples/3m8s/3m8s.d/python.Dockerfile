FROM python:3.12-alpine

RUN apk update

# install build tools
RUN apk add alpine-sdk libffi-dev

# install poetry
ENV POETRY_VERSION=1.7.1
ENV POETRY_HOME=/usr/local
ENV POETRY_VIRTUALENVS_IN_PROJECT=true
ENV POETRY_NO_INTERACTION=1
RUN curl -sSL https://install.python-poetry.org | python3 -
