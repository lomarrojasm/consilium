# syntax=docker/dockerfile:1
ARG RUBY_VERSION=3.4.2
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# 1. Instalamos Chromium, Node y fuentes esenciales para que el PDF no salga con cuadros raros
RUN echo "Construccion_Final_V4" && apt-get update -y && \
    apt-get install --no-install-recommends -y \
    curl libjemalloc2 libvips default-mysql-client default-libmysqlclient-dev \
    nodejs npm \
    chromium \
    fonts-liberation fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# 2. Activamos jemalloc y configuramos Puppeteer para Docker
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
    LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libjemalloc.so.2" \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD="true" \
    PUPPETEER_EXECUTABLE_PATH="/usr/bin/chromium"

FROM base AS build

# Instalamos herramientas de compilación
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential git pkg-config libyaml-dev default-libmysqlclient-dev

# 1. Instalar Gemas de Ruby
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    bundle exec bootsnap precompile --gemfile

# 2. INSTALAR LIBRERÍAS DE NODE (Puppeteer usará el motor nativo gracias a las ENV vars)
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

# --- Aseguramos permisos en carpetas críticas de producción ---
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp public

# --- Aseguramos que los ejecutables tengan permiso ---
RUN chmod +x bin/thrust bin/rails bin/docker-entrypoint

USER 1000:1000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]