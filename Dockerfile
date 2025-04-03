# Dockerfile to deploy a LaravelPHP app with Apache

# Use php-apache image as base
FROM php:8.4-apache
# set the working directory
WORKDIR /var/www/html
# Copy files app
COPY src .
# Copy the Laravel configuration file
COPY src/.env.example .env
# Copy the Apache configuration file
COPY apache_config/keep-app-apache.conf /etc/apache2/sites-available/000-default.conf
# Install dependencies
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    zip \
    unzip
# Clean up apt cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
# Install dependencies for PHP and Laravel
RUN docker-php-ext-install pdo_mysql &&\
    docker-php-ext-install mysqli &&\
    docker-php-ext-install zip &&\
    a2enmod rewrite
# Get Composer and install it
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
# Run composer install
RUN composer install --no-interaction --optimize-autoloader
# Run php artisan laravel commands
RUN php artisan key:generate &&\
    php artisan config:cache
# Set permissions for storage and bootstrap/cache directories
RUN chown -R www-data:www-data storage \
    && chmod -R 775 storage && chmod -R 775 bootstrap/cache
# Expose port 80 for the web server
EXPOSE 80
# Run composer install again to ensure all dependencies are installed
RUN composer install --no-interaction --optimize-autoloader
# Set the default command to run when starting the container
# This will start the Apache server
CMD ["apache2-foreground"]