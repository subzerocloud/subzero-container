# build locally for testing with
# docker build -t subzerocloud/subzero-development .
ARG REGISTRY="subzerocloud"
ARG DEVELOPMENT_BUILD="-development"
ARG POSTGREST_TAG="v7.0.1.7"
ARG OPENRESTY_TAG="1.19.3.1-alpine-v2.4"
ARG NGINX_TAG="1.19.3-alpine"

# FROM nginx:${NGINX_TAG} as nginx
FROM ${REGISTRY}/postgrest${DEVELOPMENT_BUILD}:${POSTGREST_TAG} as postgrest
FROM ${REGISTRY}/openresty${DEVELOPMENT_BUILD}:${OPENRESTY_TAG} as openresty

COPY --from=postgrest /bin/postgrest /usr/local/bin/postgrest
RUN apk add --no-cache supervisor


COPY postgrest/postgrest.conf /etc/postgrest.conf
COPY openresty/nginx /usr/local/openresty/nginx/conf
COPY openresty/html /usr/local/openresty/nginx
COPY openresty/lua /usr/local/openresty/lualib/user_code
COPY supervisord/supervisord.conf /etc/supervisord.conf
COPY supervisord/openresty.conf /etc/supervisor.d/openresty.conf
COPY supervisord/postgrest.conf /etc/supervisor.d/postgrest.conf
COPY supervisord/eventlistener.conf /etc/supervisor.d/eventlistener.conf

RUN mkdir -p /var/log/supervisor \
    && mkdir -p /var/cache/nginx && chown nobody:nogroup /var/cache/nginx


ENV DB_SCHEMA=public
ENV DB_HOST=localhost
ENV DB_PORT=5432
ENV DB_NAME=app
ENV DB_USER=authenticator
ENV DB_PASS=authenticator
ENV DB_ANON_ROLE=anonymous
ENV DEVELOPMENT=1
ENV ENABLE_CACHE=0
ENV RELAY_ID_COLUMN=id
ENV ERR_LOGLEVEL=error
ENV PGRST_DB_POOL=100
ENV PGRST_DB_POOL_TIMEOUT=10
ENV PGRST_DB_EXTRA_SEARCH_PATH=public
ENV PGRST_DB_CHANNEL=pgrst
ENV PGRST_DB_CHANNEL_ENABLED=true
# ENV PGRST_SERVER_HOST=*4
# ENV PGRST_SERVER_PORT=3000
ENV PGRST_OPENAPI_SERVER_PROXY_URI=
ENV PGRST_JWT_SECRET=
ENV PGRST_SECRET_IS_BASE64=false
ENV PGRST_JWT_AUD=
ENV PGRST_MAX_ROWS=
ENV PGRST_PRE_REQUEST=
ENV PGRST_ROLE_CLAIM_KEY=.role
ENV PGRST_ROOT_SPEC=
ENV PGRST_RAW_MEDIA_TYPES=
ENV PGRST_CUSTOM_RELATIONS=
ENV PGRST_DB_SAFE_FUNCTIONS=
ENV PGRST_LOGFILE=/dev/null
ENV PGRST_DB_URI=
ENV PGRST_DB_READ_REPLICAS_URI=
ENV PGRST_DB_SCHEMA=public
ENV PGRST_DB_ANON_ROLE=anonymous
ENV PGRST_SERVER_UNIX_SOCKET=/tmp/pgrst.sock
ENV PGRST_SERVER_UNIX_SOCKET_MODE=600
ENV PGRST_LOG_LEVEL=error
# ENV PGRST_SSL_SERVER_PORT=
# ENV PGRST_SSL_CERTIFICATE=
# ENV PGRST_SSL_CERTIFICATE_KEY=

ENV OAUTH_SUCCESS_URI=/rest/rpc/on_oauth_login
ENV OAUTH_GOOGLE_CLIENT_ID=
ENV OAUTH_GOOGLE_CLIENT_SECRET=
ENV OAUTH_GOOGLE_AUTHORIZATION_URL=https://accounts.google.com/o/oauth2/v2/auth
ENV OAUTH_GOOGLE_TOKEN_URL=https://www.googleapis.com/oauth2/v4/token
ENV OAUTH_GOOGLE_USERINFO_URL=https://www.googleapis.com/oauth2/v3/userinfo
ENV OAUTH_GOOGLE_SCOPE="email profile"

ENV OAUTH_GITHUB_CLIENT_ID=
ENV OAUTH_GITHUB_CLIENT_SECRET=
ENV OAUTH_GITHUB_AUTHORIZATION_URL=https://github.com/login/oauth/authorize
ENV OAUTH_GITHUB_TOKEN_URL=https://github.com/login/oauth/access_token
ENV OAUTH_GITHUB_USERINFO_URL=https://api.github.com/user
ENV OAUTH_GITHUB_SCOPE=user:email

ENV OAUTH_FACEBOOK_CLIENT_ID=
ENV OAUTH_FACEBOOK_CLIENT_SECRET=
ENV OAUTH_FACEBOOK_AUTHORIZATION_URL=https://www.facebook.com/v3.2/dialog/oauth
ENV OAUTH_FACEBOOK_TOKEN_URL=https://graph.facebook.com/v3.2/oauth/access_token
ENV OAUTH_FACEBOOK_USERINFO_URL=https://graph.facebook.com/v3.2/me
ENV OAUTH_FACEBOOK_SCOPE=email

ENV SSL_ALLOWED_DOMAINS=
ENV PATH=$PATH:/usr/local/openresty/openssl/bin


CMD ["/usr/bin/supervisord","-n", "-c", "/etc/supervisord.conf"]