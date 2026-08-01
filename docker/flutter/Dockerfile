FROM instrumentisto/flutter:3.24.1

WORKDIR /app

COPY . .

## Mirror selection

    #ENV PUB_HOSTED_URL=https://mirror-flutter.runflare.com
    #ENV FLUTTER_STORAGE_BASE_URL=https://mirror-gcs.runflare.com

    #ENV PUB_HOSTED_URL=https://pub.tarazerp.ir
    #ENV FLUTTER_STORAGE_BASE_URL=https://flutter.tarazerp.ir

    ENV PUB_HOSTED_URL=https://mirrors.tuna.tsinghua.edu.cn/dart-pub 
    ENV FLUTTER_STORAGE_BASE_URL=https://mirrors.tuna.tsinghua.edu.cn/flutter 

## 

RUN flutter pub get

RUN flutter build web --web-renderer canvaskit --release

FROM nginx:alpine

# Copy built files from builder stage
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration if needed
# COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf
# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]