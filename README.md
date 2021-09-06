# Terraform On Aws

Terraform On Aws

## IAM 계정 생성

`AmazonEC2FullAccess` 권한을 부여한 IAM 계정을 생성합니다.

aws-cli 를 설정합니다.

```bash
aws configure
--------------------------------------
AWS Access Key ID [None]: AKIA3VXXXXXXXXXX
AWS Secret Access Key [None]: sDSWqBzAyunFXXXXXXXXXXXXXXXXXXXXXX
Default region name [None]: ap-northeast-2
```

## 보안 그룹 생성

```bash
cd security_group

terraform init
terraform validate
terraform plan

terraform apply

# terraform destroy
```

## Consul Server Cluster 생성

```bash
cd ../consul_server_cluster

terraform init
terraform validate
terraform plan

terraform apply

# terraform destroy
```

## Nomad Server Cluster 생성

```bash
cd ../nomad_server_cluster

terraform init
terraform validate
terraform plan

terraform apply

# terraform destroy
```

## Nomad Client Cluster 생성

```bash
cd ../nomad_client_cluster

terraform init
terraform validate
terraform plan

terraform apply

# terraform destroy
```
