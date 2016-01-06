# encoding: utf-8

module Concerns::Dictionary
  module Common
    #
    # 获得i18n前缀
    #
    # @return [String] 返回
    #
    def get_i18n_prefix
      "activerecord.modules.#{self.name.underscore.gsub('/', '.')}"
    end

    #
    # 国际化
    #
    # @param value [String] 需要翻译的值
    #
    # @return [Hash] 返回
    #
    def i18n_t(value)
      return {value: '', desc: ''} if value.blank?

      value = value.to_s.downcase
      if (value.to_s =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/).present?
        value = "a#{value}"
      end

      key = "#{get_i18n_prefix}.#{value}"

      ::I18n.exists?(key) ? {value: value, desc: ::I18n.t(key)} || {value: value, desc: ''} : {value: value, desc: ''}
    end
  end

  module Attribute
    # 公共方法
    module I18n
      extend ActiveSupport::Concern

      # 类方法
      module ClassMethods
        include Concerns::Dictionary::Common

        def get_desc_by_attr(attr)
          i18n_t(attr)[:desc]
        end

        def get_i18n_prefix
          "activerecord.attributes.#{self.name.underscore.gsub('/', '.')}"
        end
      end
    end
  end

  module Module
    # 公共方法
    module I18n
      extend ActiveSupport::Concern

      # 类方法
      module ClassMethods
        include Concerns::Dictionary::Common

        #
        # 通过值获得描述
        #
        # @example
        #   Pump::Status.get_desc_by_value(Pump::Status::FOR_SALE)
        #     => "出厂待售"
        #
        def get_desc_by_value(value)
          i18n_t(value)[:desc]
        end

        #
        # 通过描述获得值
        #
        # @example
        #   Pump::Status.get_value_by_desc('关闭')
        #     => "closed"
        #
        def get_value_by_desc(desc)
          value = ''

          get_all_map.each do |m|
            value = m[:value] if m[:desc] == desc
          end

          value
        end

        #
        # 获得所有值
        #
        # @example
        #   Pump::Status.get_all_values
        #     => ["for_sale", "sold", "activate", "maintenance", "recycled", "closed"]
        #
        # @return [Array] 返回
        #
        def get_all_values
          get_all_map.map { |m| m[:value] }
        end

        #
        # 获取所有描述
        #
        # @example
        #   Pump::Status.get_all_descs
        #     => ["出厂待售", "已售出", "已激活", "维修中", "回收", "关闭"]
        #
        # @return [Array] 返回
        #
        def get_all_descs
          get_all_map.map { |m| m[:desc] }
        end

        #
        # 获取所有选项
        #
        # @example
        #   Pump::Status.get_all_options
        #     => [["出厂待售", "for_sale"],
        #         ["已售出", "sold"],
        #         ["已激活", "activate"],
        #         ["维修中", "maintenance"],
        #         ["回收", "recycled"],
        #         ["关闭", "closed"]]
        #
        # @return [Array] 返回
        #
        def get_all_options
          constants = get_all_constants

          constants.map do |constant|
            result = i18n_t(constant)

            [result[:desc], result[:value]]
          end
        end

        #
        # 获得所有映射
        #
        # @example
        #   Pump::Status.get_all_map
        #     => [{:value=>"for_sale", :desc=>"出厂待售"},
        #         {:value=>"sold", :desc=>"已售出"},
        #         {:value=>"activate", :desc=>"已激活"},
        #         {:value=>"maintenance", :desc=>"维修中"},
        #         {:value=>"recycled", :desc=>"回收"},
        #         {:value=>"closed", :desc=>"关闭"}]
        #
        # @return [Array] 返回
        #
        def get_all_map
          constants = get_all_constants

          constants.map { |constant| i18n_t(constant) }
        end

        #
        # 获得所有常量(除ALL或其他)
        #
        def get_all_constants
          constants = self.constants
          constants.delete(:ALL)
          constants.delete(:OPTIONS)
          constants.delete(:ClassMethods)
          # TODO 有新增的不需要统计在内的常量的可以继续添加

          constants
        end
      end
    end
  end
end
