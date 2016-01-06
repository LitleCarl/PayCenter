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

ActiveRecord::Schema.define(version: 20160105023920) do

  create_table "alipay_channels", force: :cascade do |t|
    t.string   "pid",               limit: 255,                comment: "PID"
    t.string   "alipay_account",    limit: 255,                comment: "支付宝账号"
    t.string   "alipay_verify_key", limit: 255,                comment: "支付宝安全校验码（Key）"
    t.text     "public_key",        limit: 65535,              comment: "支付宝公钥"
    t.text     "rsa_key",           limit: 65535,              comment: "商户RSA私钥"
    t.integer  "customer_id",       limit: 4,                  comment: "所属客户"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "apps", force: :cascade do |t|
    t.string   "name",        limit: 255,              comment: "应用名称"
    t.string   "code",        limit: 255,              comment: "app编码"
    t.integer  "customer_id", limit: 4,                comment: "关联客户"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

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
  end

  create_table "customers", force: :cascade do |t|
    t.string   "email",           limit: 255, null: false, comment: "邮箱"
    t.string   "test_key",        limit: 255, null: false, comment: "沙盒模式key"
    t.string   "live_key",        limit: 255, null: false, comment: "正式环境key"
    t.string   "company_name",    limit: 255,              comment: "公司名"
    t.string   "company_address", limit: 255,              comment: "公司地址"
    t.string   "contact_name",    limit: 255,              comment: "联系人"
    t.string   "contact_phone",   limit: 255,              comment: "联系电话"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
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
  end

end
