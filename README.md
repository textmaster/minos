# Minos

Minos is a gem created at TextMaster to ease our docker deployments on Kubernetes.

## Installation

Run:

```ruby
gem install minos
```

## Usage

Minos comes with a binary. You can see its usage with:

    $ minos help

Minos is divided into two components:

  1. Building and publishing docker artifacts
  2. Deploying docker artifacts on a Kubernetes cluster

You can use minos from docker as well:

1. Build the docker image

```sh
docker build -t textmasterapps/minos:latest .
```

2. Run:

```sh
docker run \
  -e REVISION=$REVISION \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v `pwd`:/home/runner/ \
  textmasterapps/minos:latest minos build --manifest examples/minos.yaml
```

*Mount your `.docker` directory if you want to connect to docker repository from within minos docker image*

### Build

To build docker artifacts, Minos uses a declarative config file written in YAML.
By default Minos will look for a file called `minos.yaml` under the
current directory. See `--manifest` option to provide a different config file.
For example:

```yaml
build:
  artifacts:
  - name: builder
    image: textmasterapps/foo
    tags:
    - "$TARGET"
    - "$TARGET-$REVISION"
    docker:
      # file: MyDockerfile
      tag: "$IMAGE:$TARGET" # $IMAGE and $TARGET are automatically populated as env vars for you
      target: builder
      cacheFrom:
      - textmasterapps/foo:builder
      - textmasterapps/foo:builder-$REVISION
  - name: release
    image: textmasterapps/foo
    tags:
    - "$REVISION" # you can reference ENV variables from your shell
    - "latest"
    docker:
      # file: MyDockerfile
      tag: "$IMAGE:$TARGET"
      target: release
      buildArg:
        ENV: "production"
        REVISION: "$REVISION"
      cacheFrom:
      - textmasterapps/foo:builder
      - textmasterapps/foo:release
      - textmasterapps/foo:$REVISION
      - textmasterapps/foo:latest
```

With the following `Dockerfile`, leveraging [multi-stages](https://docs.docker.com/develop/develop-images/multistage-build/):

```
######################
# Stage: builder
FROM ruby:2.5.3-alpine3.7 as builder

ENV HOME /home/app
WORKDIR $HOME

# Copy the Gemfile and Gemfile.lock
COPY Gemfile* $HOME/

# Install build deps and gems from all environments under vendor/bundle path
#
# - build-base -- used to install gcc, make, etc.
# - git -- used to install git based gems
# - libxml2-dev -- used to install nokogiri native extension
# - libxslt-dev -- used to install nokogiri native extension
RUN apk add --update --no-cache --virtual .build-deps \
    build-base \
    git \
    libxml2-dev \
    libxslt-dev \
 && bundle config build.nokogiri --use-system-libraries \
 && bundle install --frozen --deployment --jobs 4 --retry 3 \
 # Remove unneeded build deps
 && apk del .build-deps

###############################
# Stage release
FROM ruby:2.5.3-alpine3.7 as release
LABEL description="Builds a release image removing unneeded files and dependencies"

# Install runtime deps and create a non-root user
#
# - libcurl -- runtime deps for faraday
# - git -- used to run `git` command in *.gemspec
# - libxml2 -- used to run nokogiri
# - libxslt -- used to run nokogiri
# - tzdata -- used to install TZinfo data
RUN apk add --update --no-cache \
    libcurl \
    git \
    libxml2 \
    libxslt \
    tzdata

# Copy bundle config from builder stage
COPY --from=builder /usr/local/bundle/config /usr/local/bundle/config
# Copy bundled gems from builder stage
COPY --from=builder $HOME/vendor $HOME/vendor
# Copy source files according to .dockerignore policy
# Make sure your .dockerignore file is properly configure to ensure proper layer caching
COPY . $HOME

# Removes development and test gems by re-running the bundle install command
# using cached gems and simply removing unneeded gems using the clean option.
RUN bundle install --local --clean --without development test \
 # Remove unneeded cached gems
 && find vendor/bundle/ -name "*.gem" -delete \
 # Remove unneeded files and folders
 && rm -rf spec tmp/cache node_modules app/assets vendor/assets lib/assets

ENV PORT 8080
EXPOSE 8080

ENTRYPOINT ["bundle", "exec"]

CMD ["puma", "-C", "config/puma.rb"]

ARG ENV=production
ARG REVISION

ENV RAILS_ENV $ENV
ENV REVISION $REVISION
```

More details about our Dockerfiles at TextMaster can be found on our [Blog](https://medium.com/textmaster-engineering/how-textmaster-reduced-deployment-time-by-using-multi-stages-dockerfile-in-its-ci-pipeline-ffb5e153bfc7)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/textmaster/minos. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Minos project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/textmaster/minos/blob/master/CODE_OF_CONDUCT.md).
