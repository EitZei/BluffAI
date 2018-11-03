FROM mhndev/docker-lua

RUN mkdir /app

COPY main.lua /app/main.lua

CMD ["lua", "/app/main.lua"]