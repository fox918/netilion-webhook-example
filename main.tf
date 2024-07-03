terraform {
  required_providers {
    heroku = {
      source  = "heroku/heroku"
      version = "~> 5.0"
    }
  }
}
provider "heroku" {}

variable "app_name" {
  type        = string
  default     = "netilion-example-webhook"
  description = "Name of the Heroku app to create"
}

variable "webhook_secret" {
  type        = string
  description = "Webhook Secret"
}

resource "heroku_app" "webhook_poc_app" {
  name   = var.app_name
  region = "eu"

  organization {
    name = "solutions-endress"
  }

  config_vars = {
  WEBHOOK_SECRET = var.webhook_secret
  }

  buildpacks = [
    "heroku/ruby"
  ]
}

resource "heroku_build" "webhook_poc_build" {
  app_id = heroku_app.webhook_poc_app.id

  source {
    path = "app"
  }
}

resource "heroku_formation" "webhook_poc" {
  app_id     = heroku_app.webhook_poc_app.id
  type       = "web"
  quantity   = 1
  size       = "Standard-1x"
  depends_on = [heroku_build.webhook_poc_build]
}

output "app_url" {
  value = heroku_app.webhook_poc_app.web_url
}
