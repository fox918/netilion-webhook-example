# Netilion Webhook Proof of Concept

This repository contains a small proof of concept to receive measurements from multiple devices connected to the 
Netilion platform. The measurements are sent to a webhook that is implemented in this repository.

For a real implementation, it is recommended to use `asset_values_created` instead of `asset_value_created` as used here.

This PoC is not production-ready and should be used for demonstration purposes only.
It is not maintained and not endorsed by Endress + Hauser or Netilion.

## Setup
To setup the webhook, follow the instructions in the [Netilion API documentation](https://developer.netilion.endress.com/docs/api/webhooks).
For this example here I took the following steps:

1.  Create a connect subscription
2.  Create a technical user (can be done in the UI)
3.  Get the client app for the technical user (use the Swagger API-Docu)
4.  Give the technical user access to the devices (e.g. on the root node)
5.  Create a webhook using the Swagger API-Docu

## Deployment
Using the terraform file provided, you can deploy this easily to Heroku.
To run it locally, use:
```shell
rspec -I . app_rspec.rb
rackup -I . app.rb
```
