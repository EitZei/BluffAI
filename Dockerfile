FROM mhndev/docker-lua

RUN mkdir /app

WORKDIR /app

COPY lib/ /app/lib
COPY main.lua /app/main.lua

CMD ["lua", "/app/main.lua"]