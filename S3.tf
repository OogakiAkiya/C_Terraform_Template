
resource "aws_s3_bucket" "c-build-artifact"{
    bucket = "c-build-artifact"
    acl = "private"
    force_destroy = true
}

resource "aws_s3_bucket" "codepipeline_bucket"{
    bucket = "c-codepipeline-bucket"
    acl = "private"
    force_destroy = true
}
