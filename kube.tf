provider "kubernetes" {
}


resource "aws_eks_cluster" "eks" {
  name     = "eks"
  role_arn = "${aws_iam_role.eks_role.arn}"

  vpc_config {
    subnet_ids = ["${aws_subnet.main.id}", "${aws_subnet.second.id}"]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.example-AmazonEKSServicePolicy,
  ]
}

      # output "endpoint" {
      #   value = "${aws_eks_cluster.eks.endpoint}"
      # }

      # output "kubeconfig-certificate-authority-data" {
      #   value = "${aws_eks_cluster.eks.certificate_authority.0.data}"
      # }


resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks_role.name}"
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks_role.name}"
}

resource "aws_eks_node_group" "test-ng" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "test-ng"
  node_role_arn   = aws_iam_role.ng-role.arn
  subnet_ids = ["${aws_subnet.main.id}", "${aws_subnet.second.id}"]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["m5.large"]

  remote_access{
    ec2_ssh_key = "deployer-key2"
  }


  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "ng-role" {
  name = "eks-node-group-test"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.ng-role.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.ng-role.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.ng-role.name
}


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
#     namespace = "test"
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
    #      namespace = "test"
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



    
# resource "kubernetes_deployment" "customer-care-deployment" {
#   metadata {
#     name = "customer-care-deployment"
#     labels = {
#       App = "CustomerCare"
#     }
#     namespace = "behemoth"
#   }

#   spec {
#     replicas = 2
#     selector {
#       match_labels = {
#         App = "CustomerCare"
#       }
#     }
#     template {
#       metadata {
#         labels = {
#           App = "CustomerCare"
#         }
#       }
#       spec {
#         container {
#           image = "behemoth"
#           name  = "customercarebehemoth"

#           port {
#             # container_port = 80
#             container_port = 5000
#           }

#           # resources {
#           #   limits {
#           #     cpu    = "0.5"
#           #     memory = "512Mi"
#           #   }
#           #   requests {
#           #     cpu    = "250m"
#           #     memory = "50Mi"
#           #   }
#           # }
#         }
#       }
#     }
#   }
# }