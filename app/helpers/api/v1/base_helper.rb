module Api::V1::BaseHelper
  #
  # 渲染json返回属性
  #
  # @param json [Unknown] json对象
  # @param obj [ActiveRecord] 数据库表的对象
  # @param attrs [Array] 需要渲染的表属性符号数组
  #
  def render_json_attrs(json, obj, attrs)
    attrs.each do |column|
      key = column.to_sym
      value = obj.__send__(column.to_sym)

      # if value.present?
      #   # value = value.to_weinei_date if key.to_s == 'date'
      #   # value = value.to_weinei_time if key.to_s.include?('_at')
      #   # value = ObfuscateId.hide(value) if (/^([a-zA-Z]+_)*id$/ =~ key).present?
      # else
      #   value = ''
      # end

      json.__send__(key, value)
    end
  end
end