# 2.3.15 workaround 
ActionController::Base.param_parsers.delete(Mime::XML)
ActionController::Base.param_parsers.delete(Mime::YAML)
# 2.3.16 workaround
ActiveSupport::JSON.backend = "JSONGem"
