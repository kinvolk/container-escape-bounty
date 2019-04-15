output "flag_in_var_tmp" {
  value = "${random_string.flag_in_var_tmp.result}"
  sensitive = true
}

