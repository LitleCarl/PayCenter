# == Schema Information
#
# Table name: notifications
#
#  id                    :integer          not null, primary key
#  channel               :string(255)                            # 支付渠道
#  charge_id             :integer                                # 关联支付
#  received              :boolean                                # 客服服务器已接收到通知
#  send_time             :integer                                # 当前向客户服务器发送通知次数
#  original_notification :text(65535)                            # 微信服务器发来的原始通知内容
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class Notification < ActiveRecord::Base

  # 通用查询方法
  include Concerns::Query::Methods

  # 关联支付
  belongs_to :charge

  def self.create_or_update_by_alipay(options = {})
    response = Response.__rescue__ do |res|
      out_trade_no = options[:out_trade_no]
      time_paid = options[:gmt_payment]
      transaction_no = options[:trade_no]
      trade_status = options[:trade_status]
      pid = options[:seller_id]

      if trade_status != 'TRADE_SUCCESS'
        res.__raise__data_process_error('暂时不处理')
      end

      alipay_channel = AlipayChannel.query_first_by_options(pid: pid)

      res.__raise__miss_request_params('支付宝渠道错误') if alipay_channel.blank? || alipay_channel.app.blank?

      app = alipay_channel.app

      charge = app.charges.where(order_no: out_trade_no, channel: Charge::Channel::ALIPAY).first

      res.__raise__miss_request_params('支付信息不存在') if charge.blank?

      transaction do
        if charge.present?
          charge.paid = true
          charge.time_paid = time_paid
          charge.transaction_no = transaction_no
          charge.save!

          notification = self.new

          notification.charge = charge
          notification.send_time = 0
          notification.original_notification = options.to_json
          notification.save!
        end
      end
    end

    response
  end

  #
  # 处理微信异步通知
  #
  # @param options [Hash] 微信通知内容
  # @param app [APP] 应用
  #
  # @return [Response] 状态
  #
  def self.create_or_update_by_wx(options = {}, app)
    response = Response.__rescue__ do |res|
      out_trade_no = options[:out_trade_no]
      time_paid = options[:time_end]
      transaction_no = options[:transaction_id]

      res.__raise__miss_request_params('参数缺失') if app.blank?

      charge = app.charges.where(order_no: out_trade_no, channel: Charge::Channel::WX).first

      transaction do
        if charge.present?
          charge.paid = true
          charge.time_paid = time_paid
          charge.transaction_no = transaction_no
          charge.save!

          notification = self.new

          notification.charge = charge
          notification.send_time = 0
          notification.original_notification = options.to_json
          notification.save!
        end
      end
    end

    response
  end

end
