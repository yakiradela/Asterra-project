output "rds_cluster_endpoint" {
  value       = aws_rds_cluster.postgres_cluster.endpoint
  description = "The primary endpoint of the Aurora PostgreSQL cluster"
}

output "rds_cluster_reader_endpoint" {
  value       = aws_rds_cluster.postgres_cluster.reader_endpoint
  description = "The reader endpoint of the Aurora PostgreSQL cluster"
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.geojson_bucket.bucket
}

output "aws_ecr_repository_url" {
  value       = aws_ecr_repository.ecr-repo.repository_url
}
