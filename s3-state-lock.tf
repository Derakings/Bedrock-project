#resource "aws_s3_bucket" "state_lock" {
#  bucket = "dera-state-lock-bucket"

#  tags = {
#    Name        = "My bucket"
#    Environment = "prod"
#  }
#}

#resource "aws_s3_bucket_versioning" "versioning_state_lock" {
#  bucket = aws_s3_bucket.state_lock.id
#  versioning_configuration {
#    status = "Enabled"
#  }
#}
