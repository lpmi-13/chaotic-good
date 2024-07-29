locals {
  database_engine  = "aurora-postgresql"
  postgres_version = "14.9"
}

resource "aws_rds_cluster" "database" {
  cluster_identifier = "chaotic-cluster"
  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  engine             = local.database_engine
  engine_version     = local.postgres_version
  master_username    = "chaoticuser"
  master_password    = "thisisthepasswordforchaoschangelater"

  skip_final_snapshot = true

  storage_encrypted = true

  # switch this to `true` when we go to production
  deletion_protection = false

  network_type = "IPV4"

  vpc_security_group_ids = []
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 1
  identifier         = "chaotic-db"
  cluster_identifier = aws_rds_cluster.database.id
  instance_class     = "db.r6g.2xlarge"
  engine             = local.database_engine
  engine_version     = local.postgres_version

  auto_minor_version_upgrade = false
}
