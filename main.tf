# module "vpc_creation"{
#     source = "./modules/networking"
# }

# module "queue_creation"{
#     source = "./modules/queues"
#     # queue_name = "my_first_sqs"

# }

# module "lambda_creation"{
#     source = "./modules/lambda"
# }


# module "s3" {
#     source = "./modules/s3"
#     bucket_name = "prjdemobucket"       
# }

# resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
#   bucket = "prjdemobucketone"
#   rule {
#     object_ownership = "ObjectWriter"
#   }
# }

module "datalake" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket                  = "prjdemobucketonetwo"
  # acl                     = "private"  
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
  lifecycle_rule = [
    {
      id                                     = "INTELLIGENT_TIERING"
      enabled                                = "true"
      abort_incomplete_multipart_upload_days = 7
  
      transition = [
        {
          days          = 1
          storage_class = "INTELLIGENT_TIERING"
        }
      ]
      noncurrent_version_transition = [
        {
          days          = 1
          storage_class = "INTELLIGENT_TIERING"
        }
      ]
  }]
  
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_object" "this" {
  bucket = module.datalake.s3_bucket_id
  etag   = filemd5("${path.module}/us-states.csv")
  key    = "us-states.csv"
  source = "${path.module}/us-states.csv"
}

resource "aws_lakeformation_resource" "s3_bucket" {
arn = "arn:aws:s3:::prjdemobucketonetwo"
}

resource "aws_glue_catalog_database" "lakeformation_db" {
name = "glue_database"
}


resource "aws_glue_crawler" "lakeformation_db_crawler" {
database_name = "glue_database"
name = "glue_crawler"
# This was manually created
role = "arn:aws:iam::688163551818:role/service-role/AWSGlueServiceRole-GlueCrawler"
s3_target {
path = "s3://prjdemobucketonetwo"
}
}


# resource "aws_glue_connection" "this" {
#   name = "testglue"
#   connection_type = "NETWORK"
#   physical_connection_requirements {
#     # availability_zone      = data.aws_subnet.this.availability_zone
#     security_group_id_list = [aws_security_group.glue_connection.id]
#     # subnet_id              = data.aws_subnet.this.id
#   }
# }



# resource "aws_glue_catalog_database" "this" {
#     name        = "testglue"
# }

# # resource "aws_glue_crawler" "this" {
# #   database_name = aws_glue_catalog_database.this.name
# #   name          = "testglue"
# #   role          = aws_iam_role.glue_connection.arn
# # }
