# DemoPipeline

The terraform code is used to create
1. The VPC
2. Public and Private Subnets
3. Application Load Balancer with one target Group
4. Security Groups for Fargate and ALB
5. Elastic Compute Registry
6. ECS Cluster, task definition eith task execution policy and service with launch type as Fargate
<img src=./images/terr.png>

AWS CodePipeline is used for automated deployment
1. Create CodeBuild Project with source as GitHub. (make sure the privilege flag is ticked to build images using docker)
2. Add the policy 'AmazonEC2ContainerRegistryPowerUser' to the role created during the CodeBuild project which helps in connecting to the ECR
3. Create the Pipeline with Source as GitHub, CodeBuild as the build tool and ECS as the deployment destination.
