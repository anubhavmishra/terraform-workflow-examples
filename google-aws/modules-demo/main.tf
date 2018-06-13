module "webserver" {
  source   = "../."
  count    = 2
  app_name = "modules-demo"
}

output "webapp" {
  value = "${module.webserver.webapp}"
}
