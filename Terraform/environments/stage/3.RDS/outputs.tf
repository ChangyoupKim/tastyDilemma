output "rds_instance_address" {
  value       = module.tastydilemma-db.db_instance_address
  description = "DataBase Instance address"
}

output "rds_instance_port" {
  value       = module.tastydilemma-db.db_instance_port
  description = "DataBase Instance port"
}
