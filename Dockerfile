FROM golang:alpine
MAINTAINER "HashiCorp Terraform Team <terraform@hashicorp.com>"

ENV TERRAFORM_VERSION=0.10.8

RUN apk add --update git bash openssh

ENV TF_DEV=true
ENV TF_RELEASE=true

COPY . .

WORKDIR $GOPATH/src/github.com/hashicorp/terraform
RUN git clone https://github.com/hashicorp/terraform.git ./ && \
    git checkout v${TERRAFORM_VERSION} && \
    /bin/bash scripts/build.sh && \
    chmod +x /go/fingerprint.sh && \
    /bin/bash /go/fingerprint.sh

WORKDIR $GOPATH
ENTRYPOINT ["terraform"]
