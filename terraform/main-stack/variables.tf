variable "assume_role" {
  type = object({
    region   = string
    role_arn = string
  })

  default = {
    region   = "us-west-2"
    role_arn = "arn:aws:iam::659942169599:role/estudos-devops"
  }
}

variable "vpc" {

  type = object({
    name                     = string
    cidr_block               = string
    internet_gateway_name    = string
    nat_gateway_name         = string
    public_route_table_name  = string
    private_route_table_name = string
    public_subnets = list(object({
      name                    = string
      cidr_block              = string
      availability_zone       = string
      map_public_ip_on_launch = bool
    }))

    private_subnets = list(object({
      name                    = string
      cidr_block              = string
      availability_zone       = string
      map_public_ip_on_launch = bool

    }))
  })

  default = {
    name                     = "vpc-devops-na-nuvem"
    cidr_block               = "10.0.0.0/24"
    internet_gateway_name    = "internet-gateway-devops-na-nuvem"
    nat_gateway_name         = "nat-gateway-devops-na-nuvem"
    public_route_table_name  = "public-rtb-devops-na-nuvem"
    private_route_table_name = "private-rtb-devops-na-nuvem"
    public_subnets = [{
      name                    = "snet-public-devops-na-nuvem-us-west-2a"
      cidr_block              = "10.0.0.0/26"
      availability_zone       = "us-west-2a"
      map_public_ip_on_launch = true

      },

      {
        name                    = "snet-public-devops-na-nuvem-us-west-2b"
        cidr_block              = "10.0.0.64/26"
        availability_zone       = "us-west-2b"
        map_public_ip_on_launch = true

      }
    ]

    private_subnets = [
      {
        name                    = "snet-private-devops-na-nuvem-us-west-2a"
        cidr_block              = "10.0.0.128/26"
        availability_zone       = "us-west-2a"
        map_public_ip_on_launch = false

      },

      {
        name                    = "snet-private-devops-na-nuvem-us-west-2b"
        cidr_block              = "10.0.0.192/26"
        availability_zone       = "us-west-2b"
        map_public_ip_on_launch = false
      }
    ]
  }
}

variable "eks_cluster" {
  type = object({
    name                              = string
    role_name                         = string
    version                           = string
    enabled_cluster_log_types         = list(string)
    access_config_authentication_mode = string
    node_group_name                   = string
    node_group_role_name              = string
    node_group_capacity_type          = string
    node_group_instance_types         = list(string)
    node_group_scaling_desired_size   = string
    node_group_scaling_max_size       = string
    node_group_scaling_min_size       = string


  })
  default = {
    name                              = "cluster-eks-devops-na-nuvem"
    role_name                         = "DevOpsNaNuvemEKSClusterRole"
    version                           = "1.32"
    enabled_cluster_log_types         = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
    access_config_authentication_mode = "API_AND_CONFIG_MAP"
    node_group_name                   = "eks-node-group-devops-na-nuvem"
    node_group_role_name              = "DevOpsNaNuvemEKSNodeGroupRole"
    node_group_capacity_type          = "ON_DEMAND"
    node_group_instance_types         = ["t3.medium"]
    node_group_scaling_desired_size   = "2"
    node_group_scaling_max_size       = "2"
    node_group_scaling_min_size       = "2"
  }
}

variable "ecr_repositories" {
  type = list(object({
    name                 = string
    image_tag_mutability = string
    force_delete         = bool
  }))
  default = [
    {
      name                 = "devops-na-nuvem/dev/frontend"
      image_tag_mutability = "MUTABLE"
      force_delete         = true
    },
    {
      name                 = "devops-na-nuvem/dev/backend"
      image_tag_mutability = "MUTABLE"
      force_delete         = true
    }
    ,
    {
      name                 = "devops-na-nuvem/dev/strimzi/consumer"
      image_tag_mutability = "MUTABLE"
      force_delete         = true
    }
    ,
    {
      name                 = "devops-na-nuvem/dev/strimzi/producer"
      image_tag_mutability = "MUTABLE"
      force_delete         = true
    }
  ]
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "dev"
    Project     = "devops-na-nuvem"
  }
}
