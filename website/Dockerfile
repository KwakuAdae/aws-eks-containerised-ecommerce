# Kwaku Online Store: the website packaged with the NGINX web server.
# The official NGINX image is pulled from Amazon ECR Public to avoid Docker Hub download limits.
FROM public.ecr.aws/nginx/nginx:stable-alpine

COPY index.html /usr/share/nginx/html/index.html
COPY style.css /usr/share/nginx/html/style.css
COPY app.js /usr/share/nginx/html/app.js

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -q -O /dev/null http://127.0.0.1/ || exit 1
