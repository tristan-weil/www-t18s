FROM nginxinc/nginx-unprivileged:stable-alpine

RUN mkdir /etc/nginx/www

COPY Docker/nginx_default.conf /etc/nginx/conf.d/default.conf
COPY Docker/nginx_t18s.conf /etc/nginx/www/t18s.conf
COPY public/ /usr/share/nginx/html/
