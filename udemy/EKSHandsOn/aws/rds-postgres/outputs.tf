#outputs.tf

output "db_instance_endpoint" {
  value       = aws_db_instance.myrds.endpoint
}