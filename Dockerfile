###
# Global Arguments
###
ARG PHP_VERSION

###
# Set global component images
###
FROM composer:2 as COMPOSER

###
# baseline
# Create base image for baseline image build
###
FROM php:$PHP_VERSION-cli-alpine AS image_baseline

LABEL org.opencontainers.image.source=https://github.com/liquidlight/docker-php-testing
LABEL org.opencontainers.image.description="Docker image for running PHP Tests"
LABEL org.opencontainers.image.licenses=ISC

# Install dependencies
RUN apk add \
	--update \
	--no-cache \
	git

# Install XDEBUG
RUN apk add --no-cache linux-headers \
	&& apk add --update --no-cache --virtual .build-dependencies $PHPIZE_DEPS\
	&& pecl install xdebug \
	&& docker-php-ext-enable xdebug \
	&& pecl clear-cache \
	&& apk del .build-dependencies

# Copy artifaxcts from component images
COPY --from=COMPOSER /usr/bin/composer /usr/bin/composer

RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

RUN awk '/^error_reporting = E_ALL/{print "error_reporting = E_ALL & ~E_DEPRECATED"; next}1' /usr/local/etc/php/php.ini > temp.ini && mv temp.ini /usr/local/etc/php/php.ini
