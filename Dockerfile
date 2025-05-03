
FROM python:3.10 as requirements-stage

WORKDIR /tmp

RUN pip install poetry==1.5.1

COPY ./pyproject.toml ./poetry.lock* /tmp/


 RUN pip install poetry==1.5.1 uvicorn fastapi \
    && poetry install --no-dev --no-root \
    && pip freeze > requirements.txt


FROM python:3.10

WORKDIR /code

COPY --from=requirements-stage /tmp/requirements.txt /code/requirements.txt

RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

COPY . /code/

# Heroku uses PORT, Azure App Services uses WEBSITES_PORT, Fly.io uses 8080 by default
CMD ["sh", "-c", "uvicorn server.main:app --host 0.0.0.0 --port ${PORT:-${WEBSITES_PORT:-8080}}"]
