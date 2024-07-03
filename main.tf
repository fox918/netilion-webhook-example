terraform {
  required_providers {
    heroku = {
      source  = "heroku/heroku"
      version = "~> 5.0"
    }
  }
}

variable "app_name" {
  description = "Name of the Heroku app to create"
}

resource "heroku_app" "webhook_poc_app" {
  name   = var.app_name
  region = "eu"
}

resource "heroku_build" "webhook_poc_build" {
  app = heroku_app.webhook_poc_app.id

  source {
    path = "./app"
  }
}

resource "heroku_formation" "webhook_poc" {
  app        = heroku_app.webhook_poc_app.id
  type       = "web"
  quantity   = 1
  size       = "Standard-1x"
  depends_on = [heroku_build.webhook_poc_build]
}

output "app_url" {
  value = heroku_app.webhook_poc.web_url
}
```
