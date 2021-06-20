FROM google/dart-runtime

ARG DOTENV
ARG FIREBASE_SERVICE_ACCOUNT_JSON
ARG GOOGLE_PLAY_SERVICE_ACCOUNT_JSON

RUN printf "%s" "$DOTENV" > .env &&\
    printf "%s" "$FIREBASE_SERVICE_ACCOUNT_JSON" > firebase-service-account.json &&\
    printf "%s" "$GOOGLE_PLAY_SERVICE_ACCOUNT_JSON" > google-play-developer-service-account.json