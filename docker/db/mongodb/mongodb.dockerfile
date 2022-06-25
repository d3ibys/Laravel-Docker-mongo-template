FROM mongo:latest
COPY ./mongodb/loadFiles.sh /docker-entrypoint-initdb.d/
EXPOSE 27017