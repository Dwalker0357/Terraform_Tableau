output "realiti_proxy_private_ip" {
  value = aws_instance.Dale_SaaS_Realiti_Proxy_Server.private_ip
}

output "realiti_private_ip" {
  value = aws_instance.Dale_SaaS_Realiti_Server.private_ip
}

output "tableau_private_ip" {
  value = aws_instance.Dale_SaaS_Tableau_Server.private_ip
}

output "database_private_ip" {
  value = aws_instance.Dale_SaaS_Database_Server.private_ip
}

output "realiti_proxy_public_ip" {
  value = aws_eip_association.Realiti_Proxy_Elastic_IP_Association.public_ip
}

output "realiti_public_ip" {
  value = aws_eip_association.Realiti_Elastic_IP_Association.public_ip
}

output "tableau_public_ip" {
  value = aws_eip_association.Tableau_Server_Elastic_IP_Association.public_ip
}

output "database_public_ip" {
  value = aws_eip_association.Database_Server_Elastic_IP_Association.public_ip
}