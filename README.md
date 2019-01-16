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

### Build

To build docker artifacts, Minos use a declarative config file written in YAML.
By default Minos will look for a file called `docker-artifacts.yaml` under the
current directory. See `--manifest` option to provide in different config file.
For example:

```yaml
build:
  artifacts:
  - name: builder
    image: textmasterapps/foo
    tags:
    - "$TARGET-latest"
    docker:
      # file: MyDockerfile
      tag: "$IMAGE:$TARGET" # $IMAGE and $TARGET are automatically populated as env vars for you
      target: builder
      cacheFrom:
      - textmasterapps/foo:builder
      - textmasterapps/foo:builder-latest
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
      - textmasterapps/foo:$REVISION
      - textmasterapps/foo:latest
```

### Deploy

WIP

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gottfrois/minos. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Minos project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/gottfrois/minos/blob/master/CODE_OF_CONDUCT.md).
