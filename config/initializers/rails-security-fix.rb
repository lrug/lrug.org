ActionController::Base.param_parsers.delete(Mime::XML)
ActionController::Base.param_parsers.delete(Mime::YAML)
