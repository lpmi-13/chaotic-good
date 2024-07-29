resource "aws_route53_zone" "main" {
  name = "chaotic-good.org"
}

#resource "aws_route53_zone" "dev" {
#  name = "dev.example.com"
#
#  tags = {
#    Environment = "dev"
#  }
#}

#resource "aws_route53_record" "ns" {
#  zone_id = aws_route53_zone.main.zone_id
#  name    = "example.com"
#  type    = "NS"
#  ttl     = "30"
#  records = aws_route53_zone.dev.name_servers
#}
