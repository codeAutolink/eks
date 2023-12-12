module "velero" {
  source  = "terraform-module/velero/kubernetes"
  version = "1.0.0"

  velero = {
    namespace  = "velero"
    set        = {
      "configuration.backupStorageLocation.bucket"    = "mon-bucket-velero-backup",
      "configuration.backupStorageLocation.config.region" = var.region,
      "credentials.secretContents.cloud"              = var.velero_cloud_credentials,
      "initContainers[0].name"                        = "velero-plugin-for-aws",
      "initContainers[0].image"                       = "velero/velero-plugin-for-aws:v1.0.0",
      "initContainers[0].volumeMounts[0].mountPath"   = "/target",
      "initContainers[0].volumeMounts[0].name"        = "plugins",
    }
  }
}

resource "aws_iam_policy" "velero" {
  name        = "velero-policy"
  description = "Politique IAM pour Velero permettant l'accès à S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot",
        ],
        Effect   = "Allow",
        Resource = "*",
      },
      {
        Action = [
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ],
        Effect   = "Allow",
        Resource = ["arn:aws:s3:::mon-bucket-velero-backup/*"],
      },
    ],
  })
}
