# =========================================
# 1. Base image
# =========================================
FROM php:8.3-fpm

# =========================================
# 2. Apache + system libraries
# =========================================
RUN apt-get update && apt-get install -y \
    apache2 \
    git unzip pkg-config \
    libonig-dev libzip-dev libbz2-dev libxml2-dev \
    libicu-dev libpng-dev libjpeg-dev libfreetype6-dev \
    libmagickwand-dev libtidy-dev libxslt1-dev libgmp-dev \
    && rm -rf /var/lib/apt/lists/*

# =========================================
# 3. PHP extensions
# =========================================
RUN docker-php-ext-install \
    bcmath bz2 calendar exif intl mbstring mysqli pdo pdo_mysql \
    soap sockets tidy xsl gmp zip opcache ftp

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd

RUN pecl install imagick \
    && docker-php-ext-enable imagick

# =========================================
# 4. Apache modules
# =========================================
RUN a2dismod mpm_prefork && \
    a2enmod mpm_event rewrite headers expires deflate remoteip proxy_fcgi setenvif \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf


RUN echo '<FilesMatch \.php$>\n\
    SetHandler "proxy:fcgi://127.0.0.1:9000"\n\
</FilesMatch>' > /etc/apache2/conf-available/php-fpm.conf \
    && a2enconf php-fpm


COPY --from=composer:2 /usr/bin/composer /usr/bin/composer