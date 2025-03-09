FROM hashicorp/terraform:latest as builder-stage

FROM scratch
COPY --from=builder-stage /bin/terraform /

