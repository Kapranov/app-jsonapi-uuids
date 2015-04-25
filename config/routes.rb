require 'jsonapi/routing_ext'

Rails.application.routes.draw do
  UUID_regex = /[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}(,[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})*/

  jsonapi_resources :contacts, constraints: {:id => UUID_regex}
  jsonapi_resources :phone_numbers, constraints: {:id => UUID_regex}
end
