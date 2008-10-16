Merb.logger.info("Loaded DEVELOPMENT Environment...")

#::Merb::Cache.setup do

    # the order that stores are setup is important
    # faster stores should be setup first

    # page cache to the public dir
#    register(:page_store, PageStore[FileStore],
#                      :dir => Merb.root / "public" / "cache" )

    # action cache to memcache
#    register(:action_store, ActionStore[:sha_and_zip])

    # sets up the ordering of stores when attempting to read/write cache entries
#    register(:default, AdhocStore[:page_store, :action_store])

#  end

Merb::Config.use { |c|
  c[:exception_details] = true
  c[:reload_classes] = true
  c[:reload_templates] = true
  c[:reload_time] = 0.5
  c[:log_file] = Merb.log_path + "/merb.log"
}
