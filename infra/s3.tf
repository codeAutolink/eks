resource "aws_s3_bucket" "velero_backup" {
  bucket = "mon-bucket-velero-backup-${random_pet.suffix.id}"

  tags = {
    Name        = "Velero Backup Bucket"
    Environment = "Dev"
  }
}

resource "random_pet" "suffix" {
  length    = 2
  separator = "-"
}