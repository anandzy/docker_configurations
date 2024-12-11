# Use the latest Ubuntu 24.04 as the base imageFROM ubuntu:24.04# Update the apt package index and install necessary tools
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    wget \
    unzip \
    file \
    rsync \
    tree \
    vim \
    netcat-openbsd \
    nmap \
    telnet \
    traceroute \
    gnupg \
    lsb-release \
    jq \
    openjdk-11-jdk \
    dnsutils \
    && rm -rf /var/lib/apt/lists/*

# Manually install sops from GitHub releases
RUN curl -LO https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.linux \    && chmod +x sops-v3.7.3.linux \
    && mv sops-v3.7.3.linux /usr/local/bin/sops# Install AWS CLI# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \    && ./aws/install \    && rm -rf awscliv2.zip aws
# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/
# Install Terraform
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
    && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    && apt-get update && apt-get install -y terraform

# Install Terragrunt
RUN curl -L https://github.com/gruntwork-io/terragrunt/releases/download/v0.35.16/terragrunt_linux_amd64 -o /usr/local/bin/terragrunt \
    && chmod +x /usr/local/bin/terragrunt

# Install Ansible
RUN apt-get update \
    && apt-get install -y ansible

# Install Helm
RUN curl -fsSL https://get.helm.sh/helm-v3.12.3-linux-amd64.tar.gz -o helm.tar.gz \
    && tar -zxvf helm.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && rm -rf linux-amd64 helm.tar.gz

# Install Kustomize
RUN curl -LO "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v5.0.0/kustomize_v5.0.0_linux_amd64.tar.gz" \
    && tar -zxvf kustomize_v5.0.0_linux_amd64.tar.gz \
    && mv kustomize /usr/local/bin/ \
    && chmod +x /usr/local/bin/kustomize \
    && rm kustomize_v5.0.0_linux_amd64.tar.gz

# Install Flux
RUN curl -s https://fluxcd.io/install.sh | bash

# Install Helmfile
RUN curl -LO https://github.com/roboll/helmfile/releases/download/v0.143.0/helmfile_linux_amd64 \
    && chmod +x helmfile_linux_amd64 \
    && mv helmfile_linux_amd64 /usr/local/bin/helmfile

# Install Apache Kafka CLI tools and configure Amazon MSK IAM Authentication
RUN apt-get update && apt-get install -y openjdk-11-jdk && \
    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 && \
    export PATH=$PATH:$JAVA_HOME/bin && \
    wget https://archive.apache.org/dist/kafka/2.8.1/kafka_2.12-2.8.1.tgz && \
    tar -xzf kafka_2.12-2.8.1.tgz && \
    mv kafka_2.12-2.8.1 /opt/kafka && \
    rm kafka_2.12-2.8.1.tgz && \
    cd /opt/kafka/libs && \
    wget -O aws-msk-iam-auth-1.1.1-all.jar https://github.com/aws/aws-msk-iam-auth/releases/download/v1.1.1/aws-msk-iam-auth-1.1.1-all.jar

# Add Kafka CLI tools to PATH
ENV PATH="/opt/kafka/bin:${PATH}"
ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Add client.properties for Amazon MSK
# Add client.properties for Amazon MSK
RUN echo "security.protocol=SASL_SSL" > /opt/kafka/bin/client.properties && \
    echo "sasl.mechanism=AWS_MSK_IAM" >> /opt/kafka/bin/client.properties && \
    echo "sasl.jaas.config=software.amazon.msk.auth.iam.IAMLoginModule required;" >> /opt/kafka/bin/client.properties && \
    echo "sasl.client.callback.handler.class=software.amazon.msk.auth.iam.IAMClientCallbackHandler" >> /opt/kafka/bin/client.properties

RUN kubectl version --client=true

# Verify terraform
RUN terraform -version

# Verify terragrunt
RUN terragrunt -version

# Verify AWS CLI
RUN aws --version

# Verify Ansible
RUN ansible --version

# Verify Helm
RUN helm version

# Verify Kustomize
RUN kustomize version

# Verify Flux
RUN flux --version

# Verify Helmfile
RUN helmfile --version

# Verify SOPS
RUN sops --version

#User root
USER root

# Add useful aliases
RUN echo "alias k='kubectl'" >> /root/.bashrc && \
    echo "alias d='docker'" >> /root/.bashrc && \
    echo "alias c='clear'" >> /root/.bashrc && \
    echo "alias e='exit'" >> /root/.bashrc && \
    echo "alias t='terraform'" >> /root/.bashrc && \
    echo "alias a='ansible'" >> /root/.bashrc && \
    echo "alias h='helm'" >> /root/.bashrc && \
    echo "alias f='flux'" >> /root/.bashrc && \
    echo "alias kz='kustomize'" >> /root/.bashrc && \
    echo "alias tg='terragrunt'" >> /root/.bashrc && \
    echo "alias hf='helmfile'" >> /root/.bashrc

# Default command
CMD [ "bash" ]