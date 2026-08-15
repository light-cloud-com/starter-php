FROM php:8.2-apache

# Install required packages for Composer
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY composer.json composer.lock* ./
RUN composer install --no-dev --optimize-autoloader

COPY . .

RUN chown -R www-data:www-data /var/www/html

ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Configure Apache to listen on port 8080 by default
RUN sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf
RUN sed -i 's/:80/:8080/' /etc/apache2/sites-available/*.conf

EXPOSE 8080

# The platform injects the port to bind as $PORT; Apache's config must be
# rewritten at container start, not at image bake time, or it keeps listening
# on the baked-in port and fails the platform health check.
CMD ["sh", "-c", "sed -ri \"s/^Listen [0-9]+$/Listen ${PORT:-8080}/\" /etc/apache2/ports.conf && sed -ri \"s/:[0-9]+>/:${PORT:-8080}>/\" /etc/apache2/sites-available/*.conf && apache2-foreground"]
