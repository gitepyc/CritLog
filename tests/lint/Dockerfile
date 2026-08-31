FROM nickblah/lua:5.1-alpine

RUN apk add --no-cache luarocks5.1 lua5.1-dev gcc musl-dev \
    && luarocks-5.1 install luacheck \
    && apk del gcc musl-dev

WORKDIR /addon
ENTRYPOINT ["luacheck"]
