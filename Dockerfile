FROM alpine
LABEL version="1.0"
LABEL maintainer="marcos.lin@farport.co"

RUN apk update \
    && apk add --no-cache curl bash python python-dev py-setuptools make git openssh rsync \
    && /usr/bin/easy_install-2.7 pip \
    && pip install virtualenv

# Install the Google Cloud SDK.
ENV CLOUDSDK_PYTHON_SITEPACKAGES 1

# Download the file
RUN curl https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-158.0.0-linux-x86_64.tar.gz | tar zxv -C / \
    && /google-cloud-sdk/install.sh --usage-reporting=true --path-update=true --bash-completion=true --rc-path=/.bashrc --additional-components app-engine-python cloud-datastore-emulator
 
# Disable updater check for the whole installation.
# Users won't be bugged with notifications to update to the latest version of gcloud.
RUN /google-cloud-sdk/bin/gcloud config set --installation component_manager/disable_update_check true

# Disable updater completely.
# Running `gcloud components update` doesn't really do anything in a union FS.
# Changes are lost on a subsequent run.
RUN sed -i -- 's/\"disable_updater\": false/\"disable_updater\": true/g' /google-cloud-sdk/lib/googlecloudsdk/core/config.json

ENV PATH /google-cloud-sdk/bin:$PATH

VOLUME ["/root/.config", "/root/.ssh"]

# Clone git project
RUN mkdir /proj
