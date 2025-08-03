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

output "eks_cluster_endpoint" {
  description = "The endpoint URL of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_security_group_id" {
  description = "The security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "eks_node_group_role_arn" {
  description = "IAM Role ARN for the default EKS node group"
  value       = module.eks.node_group_role_arn
}

