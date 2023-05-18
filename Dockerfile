dockerfile
FROM golang:alpine AS builder
WORKDIR /app
COPY . .
RUN go build -ldflags="-w -s" -o go-chatgpt-api main.go

FROM alpine
WORKDIR /app
COPY --from=builder /app/go-chatgpt-api .
RUN apk add --no-cache tzdata
ENV TZ=Asia/Shanghai
EXPOSE 8080

# 安装 chatgpt-proxy-server 和 chatgpt-proxy-server-warp
RUN apk add --no-cache curl
RUN curl -Lo chatgpt-proxy-server https://github.com/linweiyuan/chatgpt-proxy-server/releases/download/v1.0.0/chatgpt-proxy-server-linux-amd64 && \
    chmod +x chatgpt-proxy-server
RUN curl -Lo chatgpt-proxy-server-warp https://github.com/linweiyuan/chatgpt-proxy-server/releases/download/v1.0.0/chatgpt-proxy-server-warp-linux-amd64 && \
    chmod +x chatgpt-proxy-server-warp

# 设置环境变量
ENV GIN_MODE=release
ENV CHATGPT_PROXY_SERVER=http://chatgpt-proxy-server:9515
ENV NETWORK_PROXY_SERVER=socks5://chatgpt-proxy-server-warp:65535

CMD ["./go-chatgpt-api"]
