FROM nginx:stable-alpine

RUN mkdir -p /var/cache/nginx

COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
