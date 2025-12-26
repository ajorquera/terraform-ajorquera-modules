FROM public.ecr.aws/lambda/nodejs:20

ARG GIT_COMMIT

LABEL org.opencontainers.image.revision="${GIT_COMMIT}"

# Copy function code
COPY index.mjs ${LAMBDA_TASK_ROOT}/

# Set the CMD to your handler
CMD [ "index.handler" ]
