# Docker environment for Magento 2.4 and Magento PWA

Contains of:
- nginx
- mariadb
- redis
- phpmyadmin
- maildev

## 1. Clone Magento project and Magento PWA project:
`www` is for Magento backend.
`www-front` is for Magento PWA frontend

Add into hosts:
```
127.0.0.1        magento.local magento-pwa.local
```

## 2. SSL certificate generation
Run web container to proceed with SSL cert generation
```sh
docker-compose up --build -d web
```

Generate ssl certificate for `magento.local` domain:
```sh
docker-compose exec web /bin/sh -c 'cd /usr/local/share/ca-certificates && openssl req -x509 -nodes -days 365 -subj "/C=CA/ST=QC/O=Company, Inc./CN=magento.local" -addext "subjectAltName=DNS:magento.local" -newkey rsa:2048 -keyout ./localhost-selfsigned.key -out ./localhost-selfsigned.crt && ls -la'
```

Stop web container:
```sh
docker-compose down
```

That's it, check certs in `ssl-certs` filder.

## 3. Run everything
```sh
docker-compose up --build -d
```

To check logs:
```sh
docker-compose logs -f <container-name>
```

## 4. Setup everything
Magento 2.4 - go to `docker-compose exec web /bin/sh`. And run magento installer:
```sh
bin/magento setup:install \
--base-url=https://magento.local \
--db-host=db \
--db-name=shop \
--db-user=magento \
--db-password=magento123 \
--admin-firstname=admin \
--admin-lastname=admin \
--admin-email=admin@admin.com \
--admin-user=admin \
--admin-password=admin123 \
--language=en_US \
--currency=USD \
--timezone=America/Chicago \
--use-rewrites=1 \
--elasticsearch-host=elasticsearch
```

Magento PWA - install
```sh
yarn create @magento/pwa
npx @magento/pwa-buildpack create-project . --template "venia-concept" --name "v2-3-magento-pwa" --author "Magento" --backend-url "http://web:8081/" --braintree-token "sandbox_4yrssvtm_s2bg8sdf3f4fw2qzk" --npm-client "yarn"
```

Change `.env` next params (if not already done):
```
MAGENTO_BACKEND_URL=https://web
CUSTOM_ORIGIN_EXACT_DOMAIN="0.0.0.0"
DEV_SERVER_PORT=10000
CHECKOUT_BRAINTREE_TOKEN=sandbox_4yrssvtm_s2bg8sdf3f4fw2qzk
```
