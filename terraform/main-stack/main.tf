terraform {
  backend "s3" {
    bucket = "awsiacterraformtfstate"
    key    = "mini-curso-devops-na-nuvem/kafka-tfstate"
    region = "us-west-2"
  }
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0"
    }
  }
}

provider "aws" {
  region = var.assume_role.region

  assume_role {
    role_arn = var.assume_role.role_arn # Dentro de pipelines podemos usar o assumerole
  }

  default_tags {
    tags = var.tags
  }
}
