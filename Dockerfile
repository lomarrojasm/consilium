# syntax=docker/dockerfile:1
ARG RUBY_VERSION=3.4.2
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Instalamos dependencias de ejecución + Node.js y NPM
RUN echo "Construccion_Final_V3" && apt-get update -y && \
    apt-get install --no-install-recommends -y \
    curl libjemalloc2 libvips default-mysql-client default-libmysqlclient-dev \
    nodejs npm && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

FROM base AS build

# Instalamos herramientas de compilación
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential git pkg-config libyaml-dev default-libmysqlclient-dev

# 1. Instalar Gemas de Ruby
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    bundle exec bootsnap precompile --gemfile

# 2. INSTALAR LIBRERÍAS DE NODE (Aquí estaba el fallo)
# Copiamos los archivos de configuración de Node si existen
COPY package.json package-lock.json* ./
RUN npm install

# 3. Copiar el resto del código
COPY . .

# 4. Precompilar assets
RUN bundle exec bootsnap precompile app/ lib/
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

FROM base

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]