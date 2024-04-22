terraform {
    backend "s3" {
        bucket     = "image-gallery-tfstate"
        key        = "dev/terraform.tfstate"
        region     = "us-east-1"
    }
}
