### Ubuntu Based

Following ubuntu docker file:

```
FROM ubuntu:16.04

# Setup Python
RUN echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
# Development files
        build-essential \
        git \
# Python libraries
        python \
        python-dev \
        python-setuptools \
# Utilities
        curl

# Configure Python
RUN apt-get clean \
    && easy_install -U pip \
    && pip install virtualenv

# Setup gcloud
COPY res/google-cloud-sdk.tar.gz /root/

# Download and install the cloud sdk
RUN cd / \
    && tar zxvf /root/google-cloud-sdk.tar.gz \
    && rm /root/google-cloud-sdk.tar.gz \
    && /google-cloud-sdk/install.sh --usage-reporting=true --path-update=true --bash-completion=true --rc-path=/.bashrc --additional-components app-engine-python cloud-datastore-emulator

# Disable updater check for the whole installation.
# Users won't be bugged with notifications to update to the latest version of gcloud.
RUN /google-cloud-sdk/bin/gcloud config set --installation component_manager/disable_update_check true

# Disable updater completely.
# Running `gcloud components update` doesn't really do anything in a union FS.
# Changes are lost on a subsequent run.
RUN sed -i -- 's/\"disable_updater\": false/\"disable_updater\": true/g' /google-cloud-sdk/lib/googlecloudsdk/core/config.json

ENV PATH /google-cloud-sdk/bin:$PATH
```

Result in:

```
REPOSITORY                     TAG                 IMAGE ID            CREATED             SIZE
gae-python2-dev                latest              24586dd0b7d5        24 seconds ago      793 MB
```
