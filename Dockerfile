FROM golang AS build
# renovate: name=kubernetes-sigs/cluster-api-provider-openstack repo=https://github.com/kubernetes-sigs/cluster-api-provider-openstack.git branch=release-0.11
ARG CAPO_GIT_REF=dcf91abef5c8500c1d8894a8e0f00d136977d27b
ADD https://github.com/kubernetes-sigs/cluster-api-provider-openstack.git#${CAPO_GIT_REF} /src
WORKDIR /src
COPY /patches /patches
RUN git apply /patches/*.patch
ARG ARCH
RUN CGO_ENABLED=0 GOOS=linux GOARCH=${ARCH} \
    go build -ldflags "-extldflags '-static'" -o manager ${package}

FROM ghcr.io/vexxhost/ubuntu:edge
COPY --from=build --link /src/manager /manager
USER 65532
ENTRYPOINT ["/manager"]
