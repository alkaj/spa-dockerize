FROM nginx:alpine
ARG BUILD_OUTPUT
# Move to the production ready directory
COPY $BUILD_OUTPUT /usr/share/nginx/html
# Create the js encoder file
RUN echo 'function encoder(r) { \
    var s = "?"; \
    for (var a in r.args) { \
        s += a + "=" + r.args[a] + "&" ; \
    } \
    if (s.indexOf("&") == s.length - 1) s = s.substr(0, s.length - 1); \
    if (s.indexOf("?") == s.length - 1) s = s.substr(0, s.length - 1); \
    return r.uri + encodeURIComponent(s); \
}' >> /etc/nginx/encoder.js
# Load the js module
RUN sed -i '1 i load_module /usr/lib/nginx/modules/ngx_http_js_module.so;' /etc/nginx/nginx.conf
# Include the encoder js file
RUN sed -i '/http {/ a js_include encoder.js; \
            js_set $encoded_request_uri encoder;' /etc/nginx/nginx.conf
# Enable compression
RUN sed -i '/index.html;/ a \
            gzip on; \
            gzip_proxied no-cache no-store private expired auth; \
            gzip_min_length 1000; \
            gunzip on;' \
    /etc/nginx/conf.d/default.conf
# Add expire headers gzip and make sure 404s end up on index.html
RUN sed -i '/location \// a \
            charset utf-8; \
            resolver 8.8.8.8; \
            # Send bot calls to rendertron \
            if ($http_user_agent ~* "(google|facebookexternalhit|twitter|whatsapp|telegram|baidu|duckduckgo|yahoo|yandex|ask|aol|bing|archive|wolfram)") { \
                proxy_pass https://render-tron.appspot.com/render/https://$http_host$encoded_request_uri; \
                break; \
            } \
            # Send everything to index.html \
            try_files $uri $uri/ /index.html; \
            # Enable gzip compression \
            gzip_static on; \
            gzip on; \
            gunzip on; \
            gzip_proxied no-cache no-store private expired auth; \
            gzip_types text/plain application/xml application/javascript image/svg+xml text/css image/png; \
            gzip_min_length 1000;' \
    /etc/nginx/conf.d/default.conf
# Make sure to intercept assets requests here
RUN sed -i '/location \// i \
            # Cache assets \
            location ~ ^/(assets|robots|sitemap|ads) {\
                root /usr/share/nginx/html; \
                expires 30d;\
                access_log off;\
                add_header Pragma public;\
                add_header Cache-Control "public";\
                break;\
            }' \
    /etc/nginx/conf.d/default.conf
