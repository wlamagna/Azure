FROM nginx:alpine
WORKDIR /usr/share/nginx/html/
COPY default.conf /etc/nginx/conf.d/default.conf
COPY . .
EXPOSE 5000
CMD ["nginx", "-g", "daemon off;"]
