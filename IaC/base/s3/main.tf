resource "aws_s3_bucket" "bucket" {
    bucket        = var.bucket_name
    force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "website" {
    count = var.is_website ? 1 : 0
    bucket = aws_s3_bucket.bucket.id
    index_document {
        suffix = "index.html"
    }
    error_document {
        key = "index.html"
    }
}

resource "aws_s3_bucket_public_access_block" "bucket" {
    bucket                  = aws_s3_bucket.bucket.id
    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_public_read" {
    bucket = aws_s3_bucket.bucket.id
    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource" = "${aws_s3_bucket.bucket.arn}/*"
        }]
    })
}

resource "aws_iam_policy" "s3_crud_policy" {
    name   = "${var.bucket_name}-crud-policy"
    path   = "/"
    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [{
            "Action": [
                "s3:ListObjects",
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
            ],
            "Resource": "${aws_s3_bucket.bucket.arn}*",
            "Effect": "Allow"
        }]
    })
}

resource "aws_s3_object" "static_files" {
    for_each     = var.template_files
    bucket       = aws_s3_bucket.bucket.id
    key          = each.key
    content_type = each.value.content_type
    source       = each.value.source_path
    content      = each.value.content
    etag         = each.value.digests.md5
}


output "bucket_policy_arn" {
    value = aws_iam_policy.s3_crud_policy.arn
}
output "bucket_name" {
    value = aws_s3_bucket.bucket.id
}
output "bucket_url" {
    value = "https://${aws_s3_bucket.bucket.bucket_domain_name}"
}
output "website_url" {
    value = one(aws_s3_bucket_website_configuration.website[*].website_endpoint)
}
