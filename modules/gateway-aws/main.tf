data "aws_ssm_parameter" "ami" {
  name = var.architecture == "arm64" ? "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64" : "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_ssm_parameter" "api_token" {
  name  = "/onepam/gateway/${var.gateway_id}/api-token"
  type  = "SecureString"
  value = var.api_token
  tags  = var.tags
}

resource "aws_ssm_parameter" "s3_access_key" {
  name  = "/onepam/gateway/${var.gateway_id}/s3-access-key"
  type  = "SecureString"
  value = var.s3_access_key
  tags  = var.tags
}

resource "aws_ssm_parameter" "s3_secret_key" {
  name  = "/onepam/gateway/${var.gateway_id}/s3-secret-key"
  type  = "SecureString"
  value = var.s3_secret_key
  tags  = var.tags
}

resource "aws_iam_role" "gateway" {
  name = "onepam-gateway-${var.gateway_id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.gateway.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"
}

resource "aws_iam_role_policy" "secrets" {
  name = "read-gateway-secrets"
  role = aws_iam_role.gateway.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ssm:GetParameter", "ssm:GetParameters"]
      Resource = "arn:aws:ssm:*:*:parameter/onepam/gateway/${var.gateway_id}/*"
    }]
  })
}

resource "aws_iam_role_policy" "s3" {
  name = "upload-recordings"
  role = aws_iam_role.gateway.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:PutObject", "s3:GetObject", "s3:ListBucket", "s3:GetBucketLocation"]
      Resource = ["arn:aws:s3:::${var.s3_bucket}", "arn:aws:s3:::${var.s3_bucket}/*"]
    }]
  })
}

resource "aws_iam_instance_profile" "gateway" {
  name = "onepam-gateway-${var.gateway_id}"
  role = aws_iam_role.gateway.name
  tags = var.tags
}

resource "aws_security_group" "gateway" {
  name_prefix = "onepam-gateway-"
  description = "OnePAM Gateway — HTTPS, mTLS, and WireGuard VPN"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "onepam-gateway-${var.gateway_id}" })

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  dynamic "ingress" {
    for_each = var.enable_mtls ? [1] : []
    content {
      description      = "mTLS agent tunnels"
      from_port        = 9443
      to_port          = 9443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  dynamic "ingress" {
    for_each = var.enable_vpn ? [1] : []
    content {
      description      = "WireGuard VPN"
      from_port        = 51820
      to_port          = 51820
      protocol         = "udp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
}

resource "aws_launch_template" "gateway" {
  name_prefix   = "onepam-gateway-"
  image_id      = data.aws_ssm_parameter.ami.value
  instance_type = var.instance_type

  iam_instance_profile {
    arn = aws_iam_instance_profile.gateway.arn
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.gateway.id]
  }

  user_data = base64encode(templatefile("${path.module}/templates/gateway-userdata.sh.tftpl", {
    gateway_id    = var.gateway_id
    api_url       = var.api_url
    s3_endpoint   = var.s3_endpoint
    s3_bucket     = var.s3_bucket
    s3_region     = var.s3_region
    s3_path_style = var.s3_path_style ? "1" : "0"
    public_domain = var.public_domain
    acme_enabled  = var.acme_enabled ? "1" : "0"
    acme_email    = var.acme_email
    enable_vpn    = var.enable_vpn ? "1" : "0"
    enable_mtls   = var.enable_mtls ? "1" : "0"
    architecture  = var.architecture
  }))

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "OnePAM-Gateway", "onepam:gateway-id" = var.gateway_id })
  }
}

resource "aws_autoscaling_group" "gateway" {
  name                = "onepam-gateway-${var.gateway_id}"
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = [var.subnet_id]

  launch_template {
    id      = aws_launch_template.gateway.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "OnePAM-Gateway"
    propagate_at_launch = true
  }
}
