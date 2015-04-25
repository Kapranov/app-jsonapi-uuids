ActiveRecord::Schema.define(version: 20150425151830) do

  enable_extension "uuid-ossp"

  create_table "contacts", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "twitter"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "phone_numbers", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "contact_id"
    t.string   "name"
    t.string   "phone_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
