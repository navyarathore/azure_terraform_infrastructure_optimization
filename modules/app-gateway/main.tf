
resource "azurerm_resource_group" "appgw_rg" {
  name     = "${var.environment}-${var.project_name}-appgw-rg"
  location = var.location
  tags     = var.tags
}

resource "tls_private_key" "ssl_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ssl_cert" {
  private_key_pem = tls_private_key.ssl_key.private_key_pem

  subject {
    common_name  = var.ssl_certificate_common_name
    organization = var.project_name
  }

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "terraform_data" "ssl_cert_pfx" {
  triggers_replace = {
    cert_pem = tls_self_signed_cert.ssl_cert.cert_pem
    key_pem  = tls_private_key.ssl_key.private_key_pem
  }

  provisioner "local-exec" {
    command = <<-EOT
      cat > /tmp/cert_${var.environment}.pem <<'EOF'
${tls_self_signed_cert.ssl_cert.cert_pem}
EOF
      cat > /tmp/key_${var.environment}.pem <<'EOF'
${tls_private_key.ssl_key.private_key_pem}
EOF
      openssl pkcs12 -export -out /tmp/certificate_${var.environment}.pfx \
        -inkey /tmp/key_${var.environment}.pem \
        -in /tmp/cert_${var.environment}.pem \
        -password pass:${var.ssl_certificate_password}
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f /tmp/cert_${self.triggers_replace.cert_pem} /tmp/key_${self.triggers_replace.key_pem} /tmp/certificate_*.pfx || true"
  }
}

data "local_file" "ssl_cert_pfx" {
  filename   = "/tmp/certificate_${var.environment}.pfx"
  depends_on = [terraform_data.ssl_cert_pfx]
}

resource "azurerm_application_gateway" "app_gateway" {
  name                = "${var.environment}-${var.project_name}-appgw"
  resource_group_name = azurerm_resource_group.appgw_rg.name
  location            = azurerm_resource_group.appgw_rg.location
  tags                = var.tags

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.capacity
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = var.public_ip_id
  }

  ssl_certificate {
    name     = "ssl-cert"
    data     = base64encode(data.local_file.ssl_cert_pfx.content)
    password = var.ssl_certificate_password
  }

  backend_address_pool {
    name = "backend-pool"
  }

  backend_http_settings {
    name                                = "https-backend-settings"
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 60
    probe_name                          = "https-health-probe"
    pick_host_name_from_backend_address = true
  }

  backend_http_settings {
    name                                = "http-backend-settings"
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 60
    probe_name                          = "http-health-probe"
    pick_host_name_from_backend_address = true
  }

  probe {
    name                                      = "https-health-probe"
    protocol                                  = "Https"
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
    match {
      status_code = ["200-399"]
    }
  }

  probe {
    name                                      = "http-health-probe"
    protocol                                  = "Http"
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
    match {
      status_code = ["200-399"]
    }
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name             = "https-port"
    protocol                       = "Https"
    ssl_certificate_name           = "ssl-cert"
  }

  redirect_configuration {
    name                 = "http-to-https-redirect"
    redirect_type        = "Permanent"
    target_listener_name = "https-listener"
    include_path         = true
    include_query_string = true
  }

  request_routing_rule {
    name                        = "http-redirect-rule"
    rule_type                   = "Basic"
    http_listener_name          = "http-listener"
    redirect_configuration_name = "http-to-https-redirect"
    priority                    = 100
  }

  request_routing_rule {
    name                       = "https-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "https-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "https-backend-settings"
    priority                   = 200
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101"
  }

  dynamic "waf_configuration" {
    for_each = var.sku_tier == "WAF_v2" ? [1] : []
    content {
      enabled          = true
      firewall_mode    = "Detection"
      rule_set_type    = "OWASP"
      rule_set_version = "3.2"
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
      backend_address_pool,
      backend_http_settings,
      frontend_port,
      http_listener,
      probe,
      request_routing_rule,
      url_path_map,
      redirect_configuration
    ]
  }
}
