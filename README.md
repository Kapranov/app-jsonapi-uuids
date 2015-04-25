# Сщздание backend JSON API с использованием UUIDS

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Identify and associate your ActiveRecord models using validated UUID's.

gem 'uuid'
gem 'activesupport'
gem 'activerecord'
gem 'sqlite3'

require 'active_support'
require 'active_record'
require 'uuid'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:";

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :posts, id: false, primary_key: :uuid do |t|
    t.string :uuid, primary_key: true
    t.string :title
    t.text :content
    t.timestamps
  end
  add_index :posts, :uuid

  create_table :comments, id: false, primary_key: :uuid do |t|
    t.string :uuid, primary_key: true
    t.string :post_uuid
    t.text :content
    t.timestamps
  end
  add_index :comments, :uuid
  add_index :comments, :post_uuid
end

ActiveRecord::Reflection::AssociationReflection.class_eval do
  alias_method :derive_foreign_key_before_uses_uuids, :derive_foreign_key
  def derive_foreign_key
    key = derive_foreign_key_before_uses_uuids
    active_record.respond_to?(:uses_uuids?) && active_record.uses_uuids? ? key.sub(/_id$/, '_uuid') : key
  end
end

class UuidValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    Uuid.new(value).valid_uuid? or
      record.errors[attribute] << (options[:message] || "is not a valid UUID")
  end
end

class Uuid
  attr_reader :value

  def self.build(uuid)
    uuid.is_a?(Uuid) ? uuid : new(uuid)
  end

  def self.generate
    new(UUID.new.generate)
  end

  def initialize(value)
    @value = value.to_s
  end

  def valid_uuid?
    @value =~ /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/
  end

  alias_method :to_s, :value
end

module UsesUuids
  extend ActiveSupport::Concern

  module SetsAfterInitialize
    extend ActiveSupport::Concern
    included do
      after_initialize :set_uuid
    end
  end

  module ActiveRecord
    extend ActiveSupport::Concern

    included do
      validates_uniqueness_of :uuid
    end

    def write_attribute(attr_name, value)
      _value = value.is_a?(Uuid) ? value.to_s : value
      super(attr_name, _value)
    end

    def read_attribute_for_validation(key)
      value = super
      value.is_a?(Uuid) ? value.to_s : value
    end

    module ClassMethods
      def primary_key
        :uuid
      end

      def uses_uuids?
        true
      end
    end

  end

  included do
    validates :uuid, presence: true, uuid: true
  end

  def uuid
    return nil unless self[:uuid]
    @_uuid ||= Uuid.new(read_attribute(:uuid))
    fail unless @_uuid.valid_uuid?
    @_uuid
  end

  private

  def set_uuid
    self.uuid ||= Uuid.generate.to_s
  end

end

class Record < ActiveRecord::Base
  self.abstract_class = true
  include UsesUuids
  include UsesUuids::ActiveRecord
  include UsesUuids::SetsAfterInitialize
end

class Post < Record
  has_many :comments
end

class Comment < Record
  belongs_to :post
end

post = Post.new
# => #<Post uuid: "e2cc2bd0-6d6e-0131-2bc8-38f6b1147145", title: nil, content: nil, created_at: nil, updated_at: nil>

Post.joins(:comments).to_sql
# => "SELECT \"posts\".* FROM \"posts\" INNER JOIN \"comments\" ON \"comments\".\"post_uuid\" = \"posts\".\"uuid\""
