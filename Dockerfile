FROM nginx:alpine

LABEL org.opencontainers.image.title="codyssey-work"

ENV APP_ENV=development

COPY site/ /usr/share/nginx/html/

EXPOSE 80
