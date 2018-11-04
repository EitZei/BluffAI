FROM mhndev/docker-lua

RUN mkdir /app

WORKDIR /app

COPY lib/ /app/lib
COPY game.lua /app/game.lua

CMD ["lua", "/app/game.lua"]