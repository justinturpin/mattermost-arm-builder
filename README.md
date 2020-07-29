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


## The Webapp build

This repo will make new builds of the mattermost server with Golang, but it steals
the webapp files from the official release zip files. This is partially because it saves 
time, but also because I could not for the life of me get the webapp to build on a Raspberry pi 3b+
because it needs so much memory to do so. That thing got hot and I had to yank the cable.
