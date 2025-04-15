FROM golang:1.24 AS build
ARG CAPO_VERSION=v0.11.5
ADD https://github.com/kubernetes-sigs/cluster-api-provider-openstack.git#${CAPO_VERSION} /src
WORKDIR /src
COPY /patches /patches
RUN git apply /patches/*.patch
ARG ARCH
RUN CGO_ENABLED=0 GOOS=linux GOARCH=${ARCH} \
    go build -ldflags "-extldflags '-static'" -o manager ${package}

FROM scratch
COPY --from=build --link /src/manager /manager
USER 65532
ENTRYPOINT ["/manager"]
