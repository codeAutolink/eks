module "velero" {
  source  = "terraform-module/velero/kubernetes"
  version = "0.12.2"

  namespace_deploy            = true
  app_deploy                  = true
  cluster_name                = local.cluster_name
  openid_connect_provider_uri = "openid-configuration"
  bucket                      = aws_s3_bucket.velero_backup.bucket            

  values = [<<EOF
    # Configuration de Velero ici, comme indiqué dans la documentation
    image:
        repository: velero/velero
        tag: v1.4.2

    initContainers:
      - name: velero-plugin-for-aws
        image: velero/velero-plugin-for-aws:v1.1.0
        volumeMounts:
          - mountPath: /target
            name: plugins

    securityContext:
        fsGroup: 1337

    configuration:
        provider: aws
        backupStorageLocation:
            name: default
            provider: aws
            bucket: backup-s3
            prefix: "velero/dev/my-cluster"
            config:
                region: eu-west-2

        volumeSnapshotLocation:
            name: default
            provider: aws
            config:
                region: eu-west-2
  EOF
  ]

  vars = {
    "version" = "2.12.0"
  }

 
}


# Création de la politique IAM pour Velero
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
        Resource = "arn:aws:s3:::${aws_s3_bucket.velero_backup.bucket}/*",
      },
    ],
  })
}

# Création du rôle IAM pour Velero
resource "aws_iam_role" "velero_role" {
  name = "velero-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# Attachement de la politique IAM au rôle IAM
resource "aws_iam_role_policy_attachment" "velero_attach" {
  role       = aws_iam_role.velero_role.name
  policy_arn = aws_iam_policy.velero.arn
}
