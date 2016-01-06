# encoding: utf-8

module Concerns::Query

  # 公共方法
  module Methods
    extend ActiveSupport::Concern

    # 动态定义类方法
    included do
      #
      # 根据当前类的属性定义单个查询方法
      #
      # @example
      #   Hospital.query_first_by_id(2)
      #   => SELECT  `hospitals`.* FROM `hospitals` WHERE (`hospitals`.`deleted_at` IS NULL) AND
      #     `hospitals`.`id` = 2  ORDER BY `hospitals`.`id` ASC LIMIT 1
      #
      #   Hospital.query_by_id(2)
      #   => SELECT `hospitals`.* FROM `hospitals` WHERE (`hospitals`.`deleted_at` IS NULL) AND
      #     `hospitals`.`id` = 2
      #
      # @return [self.class|ActiveRecord::Relation, nil] 返回
      #
      self.attribute_names.each do |attr|
        define_singleton_method("query_first_by_#{attr}") do |arg|
          query_first_by_options(attr.to_sym => arg)
        end

        define_singleton_method("query_by_#{attr}") do |arg|
          query_by_options(attr.to_sym => arg)
        end
      end
    end

    # 类方法
    module ClassMethods
      #
      # 根据ID查找单条记录
      #
      # @example
      #   Hospital.query_first_by_id(2)
      #
      def query_first_by_id(id)
        # This is a stub, used for indexing
      end

      #
      # 根据ID查找多条记录
      #
      # @example
      #   Hospital.query_by_id(2)
      #
      def query_by_id(id)
        # This is a stub, used for indexing
      end

      #
      # 根据多个条件查询单个对象
      #
      # @example
      #   Hospital.query_first_by_options(id: 2)
      #
      # @param options [Hash] @see #query_by_options
      #
      # @return [self.class, nil] 返回
      #
      def query_first_by_options(options = {})
        query_by_options(options).first
      end

      #
      # 根据多个条件查询并分页
      #
      # @example
      #   Hospital.query_and_paginate_by_options(id: 2, page: 2, per: 15)
      #
      # @param options [Hash] @see #query_by_options
      #
      # @return [ActiveRecord::Relation] 返回
      #
      def query_and_paginate_by_options(options = {})
        query_by_options(options).page(options[:page].presence || 1).per(options[:per])
      end

      #
      # 通用查询方法
      #
      # @note
      #   1.根据属性名称精准匹配
      #   2.根据 like_属性名 模糊匹配
      #   3.通用查询无法满足的情况下 可在使用的模型中 override 该方法
      #     第一行应使用 xxx = super(options) 先继承通用的查询方法
      #
      # @example
      #   Hospital.query_by_options(id: 1, cn_name: 'aa')
      #     => SELECT `hospitals`.* FROM `hospitals` WHERE (`hospitals`.`deleted_at` IS NULL) AND
      #       `hospitals`.`id` = 1 AND `hospitals`.`cn_name` = 'aa'
      #
      #   Hospital.query_by_options(id: 1, like_cn_name: 'aa')
      #     => SELECT `hospitals`.* FROM `hospitals` WHERE (`hospitals`.`deleted_at` IS NULL) AND
      #       `hospitals`.`id` = 1 AND (hospitals.cn_name like '%aa%')
      #
      # @param options [Hash] 查询参数 不同的模型拥有不同的属性
      #
      # @return [ActiveRecord::Relation] 返回
      #
      def query_by_options(options = {})
        result = self.all

        if options.present?
          keys = options.keys
          keys.delete(:page)
          keys.delete(:per)

          keys.each do |key|
            value = options[key]

            if value.present? || value.to_s.length > 0
              if key == :order
                result = result.order(value) if value.present?
              else
                result = result.where(key.to_sym => value) if self.instance_methods.include?(key) || self.attribute_names.include?(key.to_s)

                if key.to_s.include?('like_')
                  attr_key = key.to_s.gsub('like_', '')

                  result = result.where("#{self.name.tableize}.#{attr_key} like ?", "%#{value}%") if self.attribute_names.include?(attr_key)
                end
              end
            end
          end
        else
          result = result.limit(25)
        end

        result
      end

      #
      # 幽灵方法
      #
      # @note
      #   目前实现 多个查询参数
      #
      # @example
      #   Tag.query_by_name_and_category('admin', 'test')
      #   => SELECT `tags`.* FROM `tags` WHERE (`tags`.`deleted_at` IS NULL) AND `tags`.`name` = 'admin'
      #       AND `tags`.`category` = 'test'
      #
      #   Tag.query_first_by_name_and_category('admin', 'test')
      #   => SELECT  `tags`.* FROM `tags` WHERE (`tags`.`deleted_at` IS NULL) AND `tags`.`name` = 'admin' AND
      #       `tags`.`category` = 'test'  ORDER BY `tags`.`id` ASC LIMIT 1
      #
      # def method_missing(name, *args)
      #   name = name.to_s
      #
      #   query_reg = /^(query_first_by)_[\w]+$|(query_by)_[\w]+$/
      #
      #   result = query_reg.match(name)
      #
      #   if result && name.include?('_and_')
      #     attrs = name.gsub(/query_first_by_|query_by_/, '').split('_and_')
      #
      #     if attrs.size > 0
      #       params = {}
      #
      #       attrs.each_with_index { |attr, i| params[attr] = args[i] }
      #
      #       __send__("#{result[1].presence || result[2]}_options", params)
      #     end
      #   else
      #     super(name.to_s, *args)
      #   end
      # end
    end
  end

end
