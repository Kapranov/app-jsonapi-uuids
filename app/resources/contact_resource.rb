require 'jsonapi/resource'

class ContactResource < JSONAPI::Resource
  attributes :id, :first_name, :last_name, :email, :twitter
  has_many :phone_numbers, acts_as_set: true
end