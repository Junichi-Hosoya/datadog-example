FROM golang:1.23.3

WORKDIR /app
COPY . .

COPY --from=datadog/serverless-init:1 /datadog-init /app/datadog-init
ENTRYPOINT ["/app/datadog-init"]
ENV DD_SERVICE=dhun-datadog-demo-run-go
ENV DD_ENV=dhun-datadog-demo
ENV DD_VERSION=1
CMD ["go", "run", "."]
