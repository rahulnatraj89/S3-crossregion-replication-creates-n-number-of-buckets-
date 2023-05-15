resource "aws_s3_bucket" "primary" {
  provider = aws.primary
  count = length(var.primary)
  bucket = var.primary[count.index]
  force_destroy = var.force_destroy
  tags = merge(var.tags,{
    Name = "${var.primary[count.index]}"
  })
}
resource "aws_s3_bucket_versioning" "primary" {
  provider = aws.primary
  count = length(var.primary)
  bucket = aws_s3_bucket.primary[count.index].id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "primary" {
  provider = aws.primary
  count = length(var.primary)
  bucket = aws_s3_bucket.primary[count.index].id
  rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }

}
resource "aws_s3_bucket_public_access_block" "primary" {
  provider = aws.primary
  count = length(var.primary)
  bucket = aws_s3_bucket.primary[count.index].id
  block_public_policy = true
  block_public_acls   = true
  restrict_public_buckets = true
  ignore_public_acls = true
}
  resource "aws_iam_user" "primary_bucket_user" {
    provider = aws.primary
    count = length(var.primary)
    name = "${var.primary[count.index]}-primary-bucket-user"    
  }
  resource "aws_iam_policy" "primary_bucket_policy" { 
    provider = aws.primary
    count = length(var.primary)
    name = "${var.primary[count.index]}-primary-bucket-policy" 
    policy = jsonencode(
      {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "arn:aws-us-gov:s3:::${var.primary[count.index]}/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets"
            ],
            "Resource": "arn:aws-us-gov:s3:::${var.primary[count.index]}/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws-us-gov:s3:::${var.primary[count.index]}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:DeleteObject",
                "s3:DeleteObjectVersion"
            ],
            "Resource": "arn:aws-us-gov:s3:::${var.primary[count.index]}/*"
        }
    ]
}
    )
    
  }
  resource "aws_iam_user_policy_attachment" "primary_bucket_policy_attachment" {
    provider = aws.primary
    count = length(var.primary)
    user = aws_iam_user.primary_bucket_user[count.index].name
    policy_arn = aws_iam_policy.primary_bucket_policy[count.index].arn   
  }
  resource "aws_s3_bucket_policy" "primary_bucket" {
    provider = aws.primary
    count = length(var.primary)
    bucket = aws_s3_bucket.primary[count.index].id
    policy = jsonencode({
    "Version": "2012-10-17",
    "Id": "Policy1643297892890",
    "Statement": [
        {
            "Sid": "Stmt1643297888916",
            "Effect": "Allow",
            "Principal": {
                "AWS":  "arn:aws-us-gov:iam::292428138239:user/${var.primary[count.index]}"
            },
            "Action": "s3:*",
            "Resource": "arn:aws-us-gov:s3:::${var.primary[count.index]}"
        }
    ]
})
}
resource "aws_s3_bucket_replication_configuration" "primary" {
  provider = aws.primary
  count = length(var.primary)
  depends_on = [aws_s3_bucket_versioning.primary]
  role   = aws_iam_role.replication[count.index].arn
  bucket = aws_s3_bucket.primary[count.index].bucket
  rule {
    id = aws_s3_bucket.secondary[count.index].bucket
    filter {} 
    status = "Enabled"
    delete_marker_replication {
      status = "Enabled"
    }
    destination {
      bucket = aws_s3_bucket.secondary[count.index].arn
    }
  }
}
data "aws_iam_policy_document" "primary" {
  provider = aws.primary
  count = length(var.primary)
  statement {
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]
    resources = ["arn:aws-us-gov:s3:::${var.primary[count.index]}"]
  }
  statement {
    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]
    resources = ["arn:aws-us-gov:s3:::${var.primary[count.index]}/*"]
  }
}
resource "aws_s3_bucket" "secondary" {
  provider = aws.secondary
  count = length(var.secondary)
  bucket = var.secondary[count.index]
  force_destroy = var.force_destroy
  tags = merge(var.tags,{
    Name = "${var.secondary[count.index]}-s3-bucket"
  })
}
resource "aws_s3_bucket_versioning" "secondary" {
  provider = aws.secondary
  count = length(var.secondary)
  bucket = aws_s3_bucket.secondary[count.index].id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "secondary" {
  provider = aws.secondary
  count = length(var.secondary)
  bucket = aws_s3_bucket.secondary[count.index].id
  rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }

}
resource "aws_s3_bucket_public_access_block" "secondary" {
  provider = aws.secondary
  count = length(var.secondary)
  bucket = aws_s3_bucket.secondary[count.index].id
  block_public_policy = true
  block_public_acls   = true
  restrict_public_buckets = true
  ignore_public_acls = true
}
  resource "aws_iam_user" "secondary_bucket_user" {
    provider = aws.secondary
    count = length(var.secondary)
    name = "${var.secondary[count.index]}-secondary-bucket-user"    
  }
  resource "aws_iam_policy" "secondary_bucket_policy" { 
    provider = aws.secondary
    count = length(var.secondary)
    name = "${var.secondary[count.index]}-secondary-bucket-policy" 
    policy = jsonencode(
      {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "arn:aws-us-gov:s3:::${var.secondary[count.index]}/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets"
            ],
            "Resource": "arn:aws-us-gov:s3:::${var.secondary[count.index]}/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws-us-gov:s3:::${var.secondary[count.index]}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:DeleteObject",
                "s3:DeleteObjectVersion"
            ],
            "Resource": "arn:aws-us-gov:s3:::${var.secondary[count.index]}/*"
        }
    ]
}
    )
    
  }
  resource "aws_iam_user_policy_attachment" "secondary_bucket_policy_attachment" {
    provider = aws.secondary
    count = length(var.secondary)
    user = aws_iam_user.secondary_bucket_user[count.index].name
    policy_arn = aws_iam_policy.secondary_bucket_policy[count.index].arn   
  }
  resource "aws_s3_bucket_policy" "secondary_bucket" {
    provider = aws.secondary
    count = length(var.secondary)
    bucket = aws_s3_bucket.secondary[count.index].id
    policy = jsonencode({
    "Version": "2012-10-17",
    "Id": "Policy1643297892890",
    "Statement": [
        {
            "Sid": "Stmt1643297888916",
            "Effect": "Allow",
            "Principal": {
                "AWS":  "arn:aws-us-gov:iam::292428138239:user/${var.secondary[count.index]}"
            },
            "Action": "s3:*",
            "Resource": "arn:aws-us-gov:s3:::${var.secondary[count.index]}"
        }
    ]
})
}
data "aws_iam_policy_document" "secondary" {
  provider = aws.secondary
  count = length(var.secondary)
  statement {
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${aws_s3_bucket.secondary[count.index].arn}/*"]
  }
}
resource "aws_iam_role" "replication" {
  provider = aws.primary
  count = length(var.primary)
  assume_role_policy = data.aws_iam_policy_document.s3-assume-role[count.index].json
}
resource "aws_iam_role_policy" "replication-primary" {
  provider = aws.primary
  count = length(var.primary)
  name   = "primary"
  role   = aws_iam_role.replication[count.index].name
  policy = data.aws_iam_policy_document.primary[count.index].json
}
resource "aws_iam_role_policy" "replication-secondary" {
  provider = aws.primary
  count = length(var.secondary)
  name   = "secondary"
  role   = aws_iam_role.replication[count.index].name
  policy = data.aws_iam_policy_document.secondary[count.index].json
}
data "aws_iam_policy_document" "s3-assume-role" {
  provider = aws.primary
  count = length(var.primary)
  statement {
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}
