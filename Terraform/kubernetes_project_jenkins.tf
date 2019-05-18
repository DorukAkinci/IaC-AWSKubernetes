resource "kubernetes_deployment" "jenkins" {
  metadata {
    name = "tf-jenkins-deployment"

    labels {
      project = "jenkins"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels {
        project = "jenkins"
      }
    }

    template {
      metadata {
        labels {
          project = "jenkins"
        }
      }

      spec {
        service_account_name = "jenkins"
        container {
          image = "dorukakinci/jenkins:latest"
          name  = "jenkins"
           
          volume_mount{
            name= "jenkins-home"
            mount_path= "/var/jenkins_home"
          }

          volume_mount{
            name= "docker-sock-volume"
            mount_path= "/var/run/docker.sock"
          }

          env {
            name  = "JAVA_OPTS"
            value = "-Djenkins.install.runSetupWizard=false"
          }

          port {
            name           = "http-port"
            container_port = 8080
          }

          port {
            name           = "jnlp-port"
            container_port = 50000
          }

          resources {
            limits {
              cpu    = "1"
              memory = "1024Mi"
            }

            requests {
              cpu    = "1"
              memory = "512Mi"
            }
          }
        }
        volume{
          name= "jenkins-home"
          empty_dir = {}
        }

        volume{
          name= "docker-sock-volume"
          host_path {
            path= "/var/run/docker.sock"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "jenkins" {
  metadata {
    name = "jenkins"
  }

  spec {
    selector {
      project = "${kubernetes_deployment.jenkins.metadata.0.labels.project}"
    }

    port {
      name        = "jenkins-http-port"
      port        = 8080
      target_port = 8080
    }

    port {
      name        = "jenkins-jnlp-port"
      port        = 50000
      target_port = 50000
    }

    type = "LoadBalancer"
  }
}

### JENKINS CAN DEPLOY KUBERNETES POD SLAVES WITH THIS SERVICE ACCOUNT

resource "kubernetes_service_account" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

resource "kubernetes_role" "jenkins" {
  metadata {
    name = "jenkins"
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/exec"]
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get"]
  }

  rule {
    api_groups = ["", "extensions", "apps"]
    resources  = ["deployments", "replicasets", "pods"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding" "jenkins" {
  metadata {
    name = "jenkins"
  }

  subject {
    kind = "ServiceAccount"
    name = "jenkins"
  }

  role_ref {
    kind      = "Role"
    name      = "jenkins"
    api_group = "rbac.authorization.k8s.io"
  }
}