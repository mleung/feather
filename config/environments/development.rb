Merb.logger.info("Loaded DEVELOPMENT Environment...")
Merb::Config.use { |c|
  c[:exception_details] = true
  c[:reload_classes] = true
  c[:reload_templates] = true
  c[:reload_time] = 0.5
  c[:log_file] = Merb.log_path + "/merb.log"
}
