# Infra for the Chaotic Good Project

This sets up all the infrastructure for the chaotic-good account, in a separate place from your main AWS account (the management account). The idea here is it should be completely safe to destroy this entire account if necessary (though we probably won't go that far) without impacting anything else you might need to keep safe.

It sets up the following resources:

- network (VPC/subnets/etc)
- access (IAM/security groups/etc)
- compute (ELB/ECS/RDS/etc)
- misc (cloudfront/S3/etc)
