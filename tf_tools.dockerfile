FROM python:3.9

ARG USER_NAME="default"
ARG GROUP_NAME="default"
ARG AWS_PROFILE="default"

ENV TERRAFORM_VERSION="0.14.6"
ENV TERRAGRUNT_VERSION="0.28.6"
ENV TFENV_AUTO_INSTALL="true"

ENV AWS_PROFILE="${AWS_PROFILE}"
ENV USER_NAME="${USER_NAME}"
ENV USER_ID="1000"
ENV GROUP_NAME="${USER_NAME}"
ENV GROUP_ID="1000"
ENV HOME="/opt/${USER_NAME}"
ENV LOCAL="${HOME}/.local"
ENV LOCAL_BIN="${LOCAL}/bin"
ENV PATH="${HOME}/.local/bin:${PATH}"
ENV PATH="${HOME}/.tfenv/bin:${PATH}"
ENV PATH="${HOME}/.tgenv/bin:${PATH}"

RUN apt-get update && apt-get install -y \
        git \
        gnupg \
        curl \
    && \
    rm -rf /var/lib/apt/lists/*
RUN pip install invoke

RUN groupadd --gid ${GROUP_ID} ${GROUP_NAME}
RUN useradd \
    --no-create-home \
    --home-dir ${HOME} \
    --shell /bin/bash \
    --gid ${GROUP_ID} \
    --uid ${USER_ID} \
    ${USER_NAME}
RUN chown -R ${USER_NAME}:${GROUP_NAME} ${HOME}

WORKDIR ${HOME}
USER ${USER_NAME}

# Get the [Hashicorp GPG key](https://www.hashicorp.com/security), install tfenv
# and terraform.
RUN gpg --recv-key 0x51852D87348FFC4C && \
    git clone https://github.com/tfutils/tfenv.git ${HOME}/.tfenv && \
    tfenv install ${TERRAFORM_VERSION} && \
    tfenv use ${TERRAFORM_VERSION}
RUN git clone https://github.com/cunymatthieu/tgenv.git ~/.tgenv && \
    tgenv install latest && \
    tgenv use latest

# Install AWS CLI
RUN cd ${HOME} && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install --install-dir ${LOCAL} --bin-dir ${LOCAL_BIN}
