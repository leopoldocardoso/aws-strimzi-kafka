# AWS Strimzi Kafka - DevOps na Nuvem

Este projeto demonstra uma implementação completa de uma arquitetura de microserviços usando Apache Kafka (via Strimzi) no Amazon EKS, incluindo aplicações frontend e backend, infraestrutura como código e automação de deployment.

> Projeto realizado no mini-curso DevOps na Nuvem do Kenerry Serain

## 🏗️ Arquitetura

O projeto implementa uma arquitetura moderna de microserviços na AWS com os seguintes componentes:

- **EKS Cluster**: Cluster Kubernetes gerenciado na AWS
- **Strimzi Kafka**: Apache Kafka rodando no Kubernetes
- **Frontend**: Aplicação Next.js com TypeScript e Tailwind CSS
- **Backend**: API .NET Core com Swagger
- **Producer/Consumer**: APIs Node.js para interação com Kafka
- **Load Balancer**: AWS Application Load Balancer via Ingress Controller

## 📁 Estrutura do Projeto

```
├── terraform/           # Infraestrutura como código
│   └── main-stack/     # Stack principal do Terraform
├── ansible/            # Automação de configuração
├── apps/               # Aplicações
│   ├── frontend/       # App Next.js
│   └── backend/        # API .NET Core
├── kubernetes/         # Manifests Kubernetes
├── strimzi/           # Configurações Kafka/Strimzi
│   ├── manifests/     # Manifests do cluster Kafka
│   ├── node-api-producer/  # API Producer
│   └── node-api-consumer/  # API Consumer
└── .infracost/        # Análise de custos
```

## 🚀 Componentes

### Infraestrutura (Terraform)

A infraestrutura é provisionada usando Terraform e inclui:

- **VPC**: Rede virtual com subnets públicas e privadas
- **EKS Cluster**: Kubernetes v1.32 com node groups
- **ECR Repositories**: Repositórios para imagens Docker
- **IAM Roles**: Roles necessárias para EKS e node groups
- **Security Groups**: Configurações de segurança
- **NAT Gateway**: Para acesso à internet das subnets privadas

### Aplicações

#### Frontend (Next.js)
- Framework: Next.js 14.1.0
- Linguagem: TypeScript
- Estilização: Tailwind CSS
- Build: Docker multi-stage

#### Backend (.NET Core)
- Framework: ASP.NET Core
- Documentação: Swagger/OpenAPI
- Health Checks: Endpoint `/health`
- Containerização: Docker

#### Kafka Producer/Consumer (Node.js)
- **Producer**: API REST para envio de mensagens
  - Endpoint: `POST /send`
  - Parâmetros: `topic`, `message`
  
- **Consumer**: API REST para consumo de mensagens
  - Endpoint: `GET /consume?topic=<topic_name>`
  - Group ID: `my-group`

### Strimzi Kafka

Configuração do cluster Kafka:
- **Versão**: 4.0.0
- **Modo**: KRaft (sem Zookeeper)
- **Listeners**: Plain (9092) e TLS (9093)
- **Replicação**: Configurada para ambiente de desenvolvimento

## 🛠️ Pré-requisitos

- AWS CLI configurado
- Terraform >= 1.0
- kubectl
- eksctl
- Helm
- Docker
- Ansible (opcional)

## 📋 Deploy

### 1. Infraestrutura

```bash
cd terraform/main-stack
terraform init
terraform plan
terraform apply
```

### 2. Configurar kubectl

```bash
aws eks update-kubeconfig --region us-west-2 --name cluster-eks-devops-na-nuvem
```

### 3. AWS Load Balancer Controller (Ansible)

```bash
cd ansible
ansible-playbook site.yml
```

### 4. Deploy do Strimzi Operator

```bash
kubectl create namespace kafka
kubectl apply -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka
```

### 5. Deploy do Cluster Kafka

```bash
kubectl apply -f strimzi/manifests/ -n kafka
```

### 6. Build e Push das Imagens

```bash
# Frontend
cd apps/frontend/youtube-live-app
docker build -t <account-id>.dkr.ecr.us-west-2.amazonaws.com/devops-na-nuvem/dev/frontend:latest .
docker push <account-id>.dkr.ecr.us-west-2.amazonaws.com/devops-na-nuvem/dev/frontend:latest

# Backend
cd apps/backend/YoutubeLiveApp
docker build -t <account-id>.dkr.ecr.us-west-2.amazonaws.com/devops-na-nuvem/dev/backend:latest .
docker push <account-id>.dkr.ecr.us-west-2.amazonaws.com/devops-na-nuvem/dev/backend:latest

# Producer
cd strimzi/node-api-producer
docker build -t <account-id>.dkr.ecr.us-west-2.amazonaws.com/devops-na-nuvem/dev/strimzi/producer:latest .
docker push <account-id>.dkr.ecr.us-west-2.amazonaws.com/devops-na-nuvem/dev/strimzi/producer:latest

# Consumer
cd strimzi/node-api-consumer
docker build -t <account-id>.dkr.ecr.us-west-2.amazonaws.com/devops-na-nuvem/dev/strimzi/consumer:latest .
docker push <account-id>.dkr.ecr.us-west-2.amazonaws.com/devops-na-nuvem/dev/strimzi/consumer:latest
```

### 7. Deploy das Aplicações

```bash
kubectl apply -f kubernetes/
kubectl apply -f strimzi/manifests/producer.yml
kubectl apply -f strimzi/manifests/consumer.yml
```

## 🔧 Configuração

### Variáveis do Terraform

As principais variáveis estão em `terraform/main-stack/variables.tf`:

- **assume_role**: Role ARN e região AWS
- **vpc**: Configurações de rede
- **eks_cluster**: Configurações do cluster EKS
- **ecr_repositories**: Repositórios ECR
- **tags**: Tags padrão dos recursos

### Endpoints

Após o deploy, os seguintes endpoints estarão disponíveis:

- **Frontend**: `http://<alb-dns>/`
- **Backend**: `http://<alb-dns>/backend`
- **Swagger**: `http://<alb-dns>/backend/swagger`
- **Health Check**: `http://<alb-dns>/backend/health`

## 📊 Monitoramento

- Health checks configurados para todas as aplicações
- Logs centralizados via CloudWatch (EKS)
- Métricas do Kafka via Strimzi

## 💰 Custos

O projeto inclui análise de custos via Infracost. Os principais recursos que geram custos:

- EKS Cluster
- EC2 Instances (Node Groups)
- NAT Gateway
- Application Load Balancer
- ECR Storage

## 🧹 Limpeza

Para remover todos os recursos:

```bash
# Remover aplicações
kubectl delete -f kubernetes/
kubectl delete -f strimzi/manifests/

# Remover infraestrutura
cd terraform/main-stack
terraform destroy
```

## 📝 Notas

- Projeto configurado para ambiente de desenvolvimento
- Replicação do Kafka configurada para 1 (não recomendado para produção)
- Usar HTTPS em produção
- Configurar backup e disaster recovery para produção

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📄 Licença

Este projeto é para fins educacionais e de demonstração.
