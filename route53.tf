resource "aws_route53_record" "webapp_dns" {
  zone_id = var.route53_zone_ids[var.aws_profile]
  name    = "${var.aws_profile}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.webapp_lb.dns_name
    zone_id                = aws_lb.webapp_lb.zone_id
    evaluate_target_health = true
  }
}