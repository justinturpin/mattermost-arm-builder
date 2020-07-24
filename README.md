# Mattermost ARM Builder

Build Mattermost for ARM so I can use it on my Raspberry Pi.

This Dockerfile is designed to be self-contained so that it can be
built with:

```
docker build -t mattermost .
```

This allows it to be built with docker buildx for multiple architectures:

```
docker buildx build --platform linux/arm/v7,linux/arm64 -t mattermost .
```

There is an automated built, but its x64 only right now until Github supports multiarch
docker images in its registry.
