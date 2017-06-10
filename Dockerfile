FROM alpine

RUN apk update \
    && apk add --no-cache wget bash python python-dev py-setuptools make git openssh rsync \
    && /usr/bin/easy_install-2.7 pip \
    && pip install virtualenv

# Install the Google Cloud SDK.
ENV HOME /
ENV CLOUDSDK_PYTHON_SITEPACKAGES 1

# Copy the gcloud sdk
COPY res/google-cloud-sdk.tar.gz /
 
# Download and install the cloud sdk
RUN tar zxvf google-cloud-sdk.tar.gz \
    && rm google-cloud-sdk.tar.gz \
    && /google-cloud-sdk/install.sh --usage-reporting=true --path-update=true --bash-completion=true --rc-path=/.bashrc --additional-components app-engine-python cloud-datastore-emulator

# Disable updater check for the whole installation.
# Users won't be bugged with notifications to update to the latest version of gcloud.
RUN /google-cloud-sdk/bin/gcloud config set --installation component_manager/disable_update_check true

# Disable updater completely.
# Running `gcloud components update` doesn't really do anything in a union FS.
# Changes are lost on a subsequent run.
RUN sed -i -- 's/\"disable_updater\": false/\"disable_updater\": true/g' /google-cloud-sdk/lib/googlecloudsdk/core/config.json

ENV PATH /google-cloud-sdk/bin:$PATH

VOLUME ["/.config"]

# Clone git project
RUN mkdir /proj
