# 베이스 이미지로 Python 사용
FROM python:3.11-slim

# 작업 디렉토리 설정
WORKDIR /app

# 시스템 패키지 설치 (Nginx 포함)
RUN apt-get update && \
    apt-get install -y nginx gcc python3-dev musl-dev && \
    rm -rf /var/lib/apt/lists/*

# Python 패키지 설치를 위한 요구사항 파일 복사
COPY requirements.txt .

# Python 패키지 설치
RUN pip install --no-cache-dir -r requirements.txt

# Flask 애플리케이션 코드 복사
COPY . .

# uWSGI 설정 파일 복사
COPY uwsgi.ini /app/uwsgi.ini

# Nginx 설정 파일 복사 및 링크 설정
COPY nginx.conf /etc/nginx/nginx.conf
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# uWSGI 소켓과 Nginx에서 사용할 소켓 디렉토리 생성
RUN mkdir -p /run/uwsgi && chown www-data:www-data /run/uwsgi

# uWSGI와 Nginx를 실행하기 위한 스크립트 생성
RUN echo "uwsgi --ini /app/uwsgi.ini &" > /start.sh && \
    echo "nginx -g 'daemon off;'" >> /start.sh && \
    chmod +x /start.sh

# 기본 포트 노출
EXPOSE 80

# 컨테이너 시작 시 실행할 명령
CMD ["/bin/sh", "/start.sh"]