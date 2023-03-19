# DemoPipeline

The Terraform code is used to create:
1. The VPC
2. Public and Private Subnets
3. Application Load Balancer with one target Group
4. Security Groups for Fargate and ALB
5. Elastic Compute Registry Repository
6. ECS Cluster, task definition with task execution policy and service with launch type as Fargate
<img src=./images/terr.png>

AWS CodePipeline is used for automated deployment:
1. The buildspec.yml file is used with AWS CodeBuild. The pre-build stage ensures that it is able to connect with ECR, the build stage builds the docker image of the application using Dockerfile and the post-build stage pushes the image into the ECR repository. The imagedefinitions.json file, stored in build artifact, describes the name of the container of the ECS task definition and the image in the ECR repository that should be used during the deployment stage.
2. In AWS console, create CodeBuild Project with source as GitHub. (make sure the privilege flag is ticked to build images using docker)
3. Add the policy 'AmazonEC2ContainerRegistryPowerUser' to the role created during the CodeBuild project which helps in connecting to the ECR
4. Create the Pipeline with Source as GitHub, CodeBuild as the build tool and ECS as the deployment destination.
<img src=./images/pipeline.png>
