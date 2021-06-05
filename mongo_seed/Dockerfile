FROM mongo
WORKDIR /avalon
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.7.3/wait /wait
RUN chmod +x /wait
CMD /wait && chmod +x import.sh && ./import.sh