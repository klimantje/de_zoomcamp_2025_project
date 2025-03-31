FROM python:3.9

RUN python3 -m venv /opt/venv

# create virtual env
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install dependencies:
COPY requirements.txt .
RUN pip install -r requirements.txt

# entrypoint is not for running with devcontainer.
# ENTRYPOINT ["python", "pipeline.py"]


# #Install terraform

# RUN apt-get update && apt-get install -y \
#     wget \
#     unzip \
#   && rm -rf /var/lib/apt/lists/*

# RUN wget --quiet https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip \
#   && unzip terraform_1.6.6_linux_amd64.zip \
#   && mv terraform /usr/bin \
#   && rm terraform_1.6.6_linux_amd64.zip

# # Install cloud sdk
# RUN wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-327.0.0-linux-x86_64.tar.gz \
#     -O /tmp/google-cloud-sdk.tar.gz | bash

# RUN mkdir -p /usr/local/gcloud \
#     && tar -C /usr/local/gcloud -xvzf /tmp/google-cloud-sdk.tar.gz \
#     && /usr/local/gcloud/google-cloud-sdk/install.sh -q

# ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

# #Install java

# # Install OpenJDK-11
# RUN apt-get update && \
#     apt-get install -y openjdk-17-jre-headless && \
#     apt-get clean;