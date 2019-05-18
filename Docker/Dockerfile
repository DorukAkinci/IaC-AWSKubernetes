FROM jenkins/jenkins:lts

# Distributed Builds plugins
RUN /usr/local/bin/install-plugins.sh ssh-slaves

# install Notifications and Publishing plugins
RUN /usr/local/bin/install-plugins.sh email-ext
RUN /usr/local/bin/install-plugins.sh mailer
RUN /usr/local/bin/install-plugins.sh slack

# Artifacts
RUN /usr/local/bin/install-plugins.sh htmlpublisher

# UI
RUN /usr/local/bin/install-plugins.sh greenballs
RUN /usr/local/bin/install-plugins.sh simple-theme-plugin

# Scaling
RUN /usr/local/bin/install-plugins.sh kubernetes

# Docker Pipeline
RUN /usr/local/bin/install-plugins.sh docker-workflow

# To change the application Language
RUN /usr/local/bin/install-plugins.sh locale

# work with pipeline
RUN /usr/local/bin/install-plugins.sh workflow-aggregator workflow-multibranch workflow-job pipeline-stage-step workflow-step-api pipeline-stage-view

#Git
RUN /usr/local/bin/install-plugins.sh git git-client github

USER root
#Add Kubectl Repo
RUN apt-get update && apt-get install -y apt-transport-https && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
# install Maven & Pip && AWSCLI && kubectl && jq
RUN apt-get update && apt-get install -y maven && apt-get install -y python-pip && pip install awscli && apt-get install -y kubectl && apt-get install -y jq

#install Docker
RUN apt-get update && \
apt-get -y install apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common && \
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey && \
add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
    $(lsb_release -cs) \
    stable" && \
apt-get update && \
apt-get -y install docker-ce
RUN apt-get install -y docker-ce
RUN usermod -a -G docker jenkins

#dotnet sdk
RUN apt-get install dotnet-sdk-2.2

USER jenkins