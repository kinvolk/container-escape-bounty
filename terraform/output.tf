output "flag_in_var_tmp" {
  value     = "${random_string.flag_in_var_tmp.result}"
  sensitive = true
}

output "password" {
  value     = "${random_string.password.result}"
  sensitive = true
}

output "apparmor_machine" {
  value = "https://${local.domain_apparmor}"
}

output "selinux_machine" {
  value = "https://${local.domain_selinux}"
}
