provider "kubernetes" {
}
        # Error: timeout while waiting for state to become 'Running' (last state: 'Pending', timeout: 5m0s)
        #    * nginx-example (Pod): FailedScheduling: 0/1 nodes are available: 1 Insufficient pods.
        #    * nginx-example (Pod): FailedScheduling: skip schedule deleting pod: default/nginx-example
        
# resource "kubernetes_pod" "nginx" {
#   metadata {
#     name = "nginx-example"
#     labels = {
#       App = "nginx"
#     }
#   }

#   spec {
#     container {
#       image = "nginx:1.7.8"
#       name  = "example"

#       port {
#         container_port = 80
#       }
#     }
#   }
# }

# resource "kubernetes_deployment" "nginx" {
#   metadata {
#     name = "scalable-nginx-example"
#     labels = {
#       App = "ScalableNginxExample"
#     }
#   }

#   spec {
#     replicas = 2
#     selector {
#       match_labels = {
#         App = "ScalableNginxExample"
#       }
#     }
#     template {
#       metadata {
#         labels = {
#           App = "ScalableNginxExample"
#         }
#       }
#       spec {
#         container {
#           image = "nginx:1.7.8"
#           name  = "example"

#           port {
#             container_port = 80
#           }

#           resources {
#             limits {
#               cpu    = "0.5"
#               memory = "512Mi"
#             }
#             requests {
#               cpu    = "250m"
#               memory = "50Mi"
#             }
#           }
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_service" "nginx-dep" {
#   metadata {
#     name = "nginx-example"
#   }
#   spec {
#     selector = {
#       App = kubernetes_deployment.nginx.spec.0.template.0.metadata[0].labels.App
#     }
#     port {
#       port        = 80
#       target_port = 80
#     }

#     type = "LoadBalancer"
#   }
# }

# resource "kubernetes_service" "nginx" {
#   metadata {
#     name = "nginx-example"
#   }
#   spec {
#     selector = {
#       App = kubernetes_pod.nginx.metadata[0].labels.App
#     }
#     port {
#       port        = 80
#       target_port = 80
#     }

#     type = "LoadBalancer"
#   }
# }

# output "lb_hostname" {
#   value = kubernetes_service.nginx.load_balancer_ingress[0].hostname
# }

# output "lb_hostname_dep" {
#   value = kubernetes_service.nginx-dep.load_balancer_ingress[0].hostname
# }