require 'jsonapi/resource_controller'

class ApplicationController < JSONAPI::ResourceController
  protect_from_forgery with: :null_session

  skip_before_action :verify_authenticity_token
end
