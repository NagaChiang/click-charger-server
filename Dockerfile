FROM google/dart-runtime

ARG DOTENV
ARG SERVICE_ACCOUNT_JSON

RUN printf "%s" "$DOTENV" > .env &&\
    printf "%s" "$SERVICE_ACCOUNT_JSON" > service-account.json