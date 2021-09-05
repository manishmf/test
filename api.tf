resource "aws_api_gateway_vpc_link" "this" {
  name        = var.aws_api_gateway_vpc_link_name
  target_arns = [aws_lb.main.arn]

  # depends_on = [aws_ec2_client_vpn_network_association.association]
  depends_on = [aws_api_gateway_vpc_link.this]
}

resource "aws_api_gateway_rest_api" "main" {
  name = var.aws_api_gateway_rest_api_name
}

resource "aws_api_gateway_resource" "main" {
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "main"
  rest_api_id = aws_api_gateway_rest_api.main.id
}

resource "aws_api_gateway_method" "main" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id

  depends_on = [
    aws_api_gateway_resource.main      
      ]

}

resource "aws_api_gateway_integration" "main" {
  http_method = aws_api_gateway_method.main.http_method
  resource_id = aws_api_gateway_resource.main.id
  rest_api_id = aws_api_gateway_rest_api.main.id
  type        = "HTTP"
  uri         = "http://${aws_lb.main.dns_name}"
  #uri         = aws_lb.main.dns_name
  #"http://${aws_alb.account-statements-webservice.dns_name}/statement/{document_id}"
  integration_http_method = "GET"
  #passthrough_behavior    = "WHEN_NO_MATCH"

  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.this.id
  depends_on = [
    aws_api_gateway_resource.main
  ]
  
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  triggers = {                           
    
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.main.id,
      aws_api_gateway_method.main.id,
      aws_api_gateway_integration.main.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = "main"
}
                         
