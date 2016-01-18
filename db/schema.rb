# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160118083626) do

  create_table "alipay_channels", force: :cascade do |t|
    t.string   "pid",               limit: 255,                comment: "PID"
    t.string   "alipay_account",    limit: 255,                comment: "支付宝账号"
    t.string   "alipay_verify_key", limit: 255,                comment: "支付宝安全校验码（Key）"
    t.text     "public_key",        limit: 65535,              comment: "支付宝公钥"
    t.text     "rsa_key",           limit: 65535,              comment: "商户RSA私钥"
    t.integer  "customer_id",       limit: 4,                  comment: "所属客户"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "app_id",            limit: 4,                  comment: "关联应用"
  end

  create_table "apps", force: :cascade do |t|
    t.string   "name",        limit: 255,              comment: "应用名称"
    t.string   "code",        limit: 255,              comment: "app编码"
    t.integer  "customer_id", limit: 4,                comment: "关联客户"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "notify_url",  limit: 255,              comment: "客户服务器异步通知地址"
  end

  create_table "authentication_tokens", force: :cascade, comment: "认证令牌" do |t|
    t.string   "auth_token",    limit: 255,              comment: "令牌内容"
    t.datetime "expired_at",                             comment: "过期时间"
    t.integer  "resource_id",   limit: 4,                comment: "多态关联"
    t.string   "resource_type", limit: 255,              comment: "多态关联"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "authentication_tokens", ["auth_token"], name: "index_authentication_tokens_on_auth_token", using: :btree
  add_index "authentication_tokens", ["resource_type", "resource_id"], name: "index_authentication_tokens_on_resource_type_and_resource_id", using: :btree

  create_table "charges", force: :cascade do |t|
    t.boolean  "live_mode",                    null: false, comment: "沙盒模式"
    t.boolean  "paid",                         null: false, comment: "已经支付"
    t.boolean  "refunded",                     null: false, comment: "已经退款"
    t.integer  "app_id",         limit: 4,                  comment: "关联的应用"
    t.string   "channel",        limit: 255,   null: false, comment: "支付渠道"
    t.string   "order_no",       limit: 255,                comment: "客户订单号"
    t.integer  "amount",         limit: 4,                  comment: "订单金额"
    t.string   "subject",        limit: 255,                comment: "交易主题"
    t.string   "body",           limit: 255,                comment: "交易介绍"
    t.datetime "time_paid",                                 comment: "支付时间"
    t.datetime "time_expired",                              comment: "失效时间"
    t.string   "transaction_no", limit: 255,                comment: "支付平台交易号"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.text     "credential",     limit: 65535,              comment: "支付渠道凭据"
    t.datetime "deleted_at",                                comment: "删除时间"
    t.string   "batch_no",       limit: 255,                comment: "支付宝用: 退款号"
  end

  create_table "customers", force: :cascade do |t|
    t.string   "email",                  limit: 255,              null: false, comment: "邮箱"
    t.string   "test_key",               limit: 255,              null: false, comment: "沙盒模式key"
    t.string   "live_key",               limit: 255,              null: false, comment: "正式环境key"
    t.string   "company_name",           limit: 255,                           comment: "公司名"
    t.string   "company_address",        limit: 255,                           comment: "公司地址"
    t.string   "contact_name",           limit: 255,                           comment: "联系人"
    t.string   "contact_phone",          limit: 255,                           comment: "联系电话"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
  end

  add_index "customers", ["email"], name: "index_customers_on_email", unique: true, using: :btree
  add_index "customers", ["reset_password_token"], name: "index_customers_on_reset_password_token", unique: true, using: :btree

  create_table "notifications", force: :cascade do |t|
    t.string   "channel",               limit: 255,                comment: "支付渠道"
    t.integer  "charge_id",             limit: 4,                  comment: "关联支付"
    t.boolean  "received",                                         comment: "客服服务器已接收到通知"
    t.integer  "send_time",             limit: 4,                  comment: "当前向客户服务器发送通知次数"
    t.text     "original_notification", limit: 65535,              comment: "微信服务器发来的原始通知内容"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "wx_channels", force: :cascade do |t|
    t.string   "wx_app_id",                 limit: 255,                comment: "微信App id"
    t.string   "wx_app_secret",             limit: 255,                comment: "微信App Secret"
    t.string   "parter_id",                 limit: 255,                comment: "商户id"
    t.text     "pay_secret",                limit: 65535,              comment: "商户支付密钥"
    t.string   "refund_operator",           limit: 255,                comment: "商户添加的退款操作员 ID"
    t.text     "client_certificate",        limit: 65535,              comment: "微信客户端证书"
    t.text     "client_certificate_secret", limit: 65535,              comment: "微信客户端证书密钥"
    t.integer  "customer_id",               limit: 4,                  comment: "所属客户"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "app_id",                    limit: 4,                  comment: "关联应用"
  end

end
