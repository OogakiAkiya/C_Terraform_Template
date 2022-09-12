

//------------------------------------
//IAM関係
//------------------------------------
data "aws_iam_policy_document" "code_pipeline"{
    statement{
        effect = "Allow"
        actions = ["sts:AssumeRole"]
        principals{
            identifiers=["codepipeline.amazonaws.com"]
            type = "Service"
        }
    }
}

resource "aws_iam_role" "code_pipeline"{
    name = "codepipeline-c-build-service-role"
    assume_role_policy = data.aws_iam_policy_document.code_pipeline.json
}

data "aws_iam_policy_document" "code_pipeline_policy"{
    statement{
        effect = "Allow"
        resources = ["*"]
        actions = ["iam:PassRole"]
        condition {
            test = "StringEqualsIfExists"
            variable = "iam:PassedToService"
            values = [
                "cloudformation.amazonaws.com",
                "elasticbeanstalk.amazonaws.com",
                "ec2.amazonaws.com",
                "ecs-tasks.amazonaws.com"
            ]
        }
    }
    
    statement{
        effect = "Allow"
        resources = ["*"]
        actions = [
            "codecommit:CancelUploadArchive",
            "codecommit:GetBranch",
            "codecommit:GetCommit",
            "codecommit:GetRepository",
            "codecommit:GetUploadArchiveStatus",
            "codecommit:UploadArchive"
        ]
    }
    statement{
        effect = "Allow"
        resources = ["*"]
        actions = [
            "codedeploy:CreateDeployment",
            "codedeploy:GetApplication",
            "codedeploy:GetApplicationRevision",
            "codedeploy:GetDeployment",
            "codedeploy:GetDeploymentConfig",
            "codedeploy:RegisterApplicationRevision"
        ]
    }
    statement{
        effect = "Allow"
        resources = ["*"]
        actions = ["codestar-connections:UseConnection"]
    }
    statement{
        effect = "Allow"
        resources = ["*"]
        actions = [
            "elasticbeanstalk:*",
            "ec2:*",
            "elasticloadbalancing:*",
            "autoscaling:*",
            "cloudwatch:*",
            "s3:*",
            "sns:*",
            "cloudformation:*",
            "rds:*",
            "sqs:*",
            "ecs:*"
        ]
    }
    statement{
        effect = "Allow"
        resources = ["*"]
        actions = [
            "lambda:InvokeFunction",
            "lambda:ListFunctions"
        ]
    }
    statement{
        effect = "Allow"
        resources = ["*"]
        actions = [
            "opsworks:CreateDeployment",
            "opsworks:DescribeApps",
            "opsworks:DescribeCommands",
            "opsworks:DescribeDeployments",
            "opsworks:DescribeInstances",
            "opsworks:DescribeStacks",
            "opsworks:UpdateApp",
            "opsworks:UpdateStack"
        ]
    }
    statement{
        effect = "Allow"
        resources = ["*"]
        actions = [
            "cloudformation:CreateStack",
            "cloudformation:DeleteStack",
            "cloudformation:DescribeStacks",
            "cloudformation:UpdateStack",
            "cloudformation:CreateChangeSet",
            "cloudformation:DeleteChangeSet",
            "cloudformation:DescribeChangeSet",
            "cloudformation:ExecuteChangeSet",
            "cloudformation:SetStackPolicy",
            "cloudformation:ValidateTemplate"
        ]
    }
    statement{
        effect = "Allow"
        resources = ["*"]
        actions = [
            "codebuild:BatchGetBuilds",
            "codebuild:StartBuild",
            "codebuild:BatchGetBuildBatches",
            "codebuild:StartBuildBatch"
        ]
    }
    statement{
        effect = "Allow"
        resources = ["*"]
        actions = [
            "devicefarm:ListProjects",
            "devicefarm:ListDevicePools",
            "devicefarm:GetRun",
            "devicefarm:GetUpload",
            "devicefarm:CreateUpload",
            "devicefarm:ScheduleRun"
        ]
    }
    statement{
        effect = "Allow"
        resources = ["*"]
        actions = [
            "servicecatalog:ListProvisioningArtifacts",
            "servicecatalog:CreateProvisioningArtifact",
            "servicecatalog:DescribeProvisioningArtifact",
            "servicecatalog:DeleteProvisioningArtifact",
            "servicecatalog:UpdateProduct"
        ]
    }
    statement{
        effect = "Allow"
        resources = ["*"]
        actions = ["cloudformation:ValidateTemplate"]
    }    
    statement{
        effect = "Allow"
        resources = ["*"]
        actions = ["ecr:DescribeImages"]
    }
    statement{
        effect = "Allow"
        resources = ["*"]
        actions = [
            "states:DescribeExecution",
            "states:DescribeStateMachine",
            "states:StartExecution"
        ]
    }
    statement{
        effect = "Allow"
        resources = ["*"]
        actions = [
            "appconfig:StartDeployment",
            "appconfig:StopDeployment",
            "appconfig:GetDeployment"
        ]
    }        
}

//自作ポリシーのアタッチ
resource "aws_iam_role_policy" "code_pipeline_policy"{
    role = aws_iam_role.code_pipeline.name
    policy= data.aws_iam_policy_document.code_pipeline_policy.json
}

//------------------------------------
//codepipeline
//------------------------------------
resource "aws_codepipeline" "codepipeline"{
    name = "C_Test"
    role_arn = aws_iam_role.code_pipeline.arn
    artifact_store{
        location = aws_s3_bucket.codepipeline_bucket.bucket
        type     = "S3"
    }

    stage{
        name = "Source"
        action{
            name = "Source"
            category = "Source"
            owner    = "AWS"
            version  = "1"
            provider = "CodeCommit"
            namespace = "SourceVariables"
            output_artifacts = ["SourceArtifact"]
            configuration = {
                RepositoryName = aws_codecommit_repository.C_Test.repository_name
                BranchName = "master"
                OutputArtifactFormat = "CODE_ZIP"
                PollForSourceChanges = true
            }
        }
    }
    stage{
        name = "Build"
        action{
            name = "Build"
            category = "Build"
            owner = "AWS"
            version = "1"
            provider = "CodeBuild"
            namespace = "BuildVariables"
            input_artifacts = ["SourceArtifact"]
            output_artifacts = ["BuildArtifact"]
            configuration = {
                ProjectName = aws_codebuild_project.build.name
            }
        }
    }
    stage{
        name = "Deploy"
        action{
            name = "Deploy"
            category="Deploy"
            owner = "AWS"
            version = "1"
            provider = "CodeDeploy"
            namespace = "DeployVariables"
            input_artifacts = ["BuildArtifact"]
            configuration = {
                ApplicationName = aws_codedeploy_app.app.name
                DeploymentGroupName = aws_codedeploy_deployment_group.group.deployment_group_name
            }
        }
    }
}


data "aws_kms_alias" "s3kmskey"{
    name = "alias/myKmsKey"
}
