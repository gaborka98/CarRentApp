FROM python:3.12-alpine

RUN adduser -DH -u 1000 -s /bin/bash django
RUN mkdir /app
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN pip install --upgrade pip

COPY --chown=django --chmod=777 . /app/

RUN chmod -R 777 /app

RUN pip install --no-cache-dir -r requirements.txt

USER django

EXPOSE 8000

ENTRYPOINT ["/bin/sh"]
CMD ["./startup.sh"]