GCP_PROJECT_ID  := $(GCP_PROJECT_ID)
DATADOG_API_KEY := $(DATADOG_API_KEY)
IMAGE_TAG       := gcr.io/${GCP_PROJECT_ID}/datadog-example

build:
	docker build --platform=linux/amd64 -t ${IMAGE_TAG} .
	docker push ${IMAGE_TAG}

# - Fix "Memory limit of 512 MiB exceeded with  526 MiB used" with `--memory=1G`
# - Fix "Memory limit of 953 MiB exceeded with 1028 MiB used" with `--memory=2G`
deploy:
	gcloud run deploy datadog-example --image=${IMAGE_TAG} \
	    --port=8080 \
	    --region=asia-northeast1 \
	    --allow-unauthenticated \
	    --memory=2G \
	    --set-env-vars=DD_API_KEY=${DATADOG_API_KEY} \
	    --set-env-vars=DD_SITE=ap1.datadoghq.com \
	    --set-env-vars=DD_LOGS_ENABLED=true

build-local:
	docker build -t ${IMAGE_TAG} .
	docker push ${IMAGE_TAG}

run-local:
	docker run --rm -p 8080:8080 \
	    -e DD_API_KEY=${DATADOG_API_KEY} \
	    -e DD_SITE=ap1.datadoghq.com \
	    -e DD_LOGS_ENABLED=true \
	    gcr.io/nobita-dev/datadog-example
