output "cluster_identifier" {
  description = "The Aurora cluster identifier"
  value       = module.aurora.cluster_identifier
}

output "cluster_endpoint" {
  description = "Writer endpoint for the Aurora cluster"
  value       = module.aurora.cluster_endpoint
}

output "cluster_reader_endpoint" {
  description = "Reader endpoint for the Aurora cluster"
  value       = module.aurora.cluster_reader_endpoint
}

output "security_group_id" {
  description = "Security group ID for the Aurora cluster"
  value       = module.aurora.security_group_id
}

output "aurora" {
  description = "All Aurora primitives as a single object for downstream stacks via remote state."
  value       = module.aurora.aurora
}
