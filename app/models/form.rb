class Form
  include ActiveModel::Model

  def self.i18n_scope
    :activerecord
  end

  def self.models(*model_names)
    model_names.map(&:to_sym).compact.each do |model_name|
      (@model_names ||= []) << model_name
      attr_accessor model_name
      define_method "#{model_name}_attributes=" do |attributes|
        instance_variable_get("@#{model_name}").assign_attributes attributes
      end
    end
  end

  def initialize(*args)
    model_names.each do |model_name|
      instance_variable_set "@#{model_name}", model_name.to_s.classify.constantize.new
    end

    super
  end

  def save(attributes)
    ActiveRecord::Base.transaction do
      model_names.each do |model_name|
        if attributes.key?("#{model_name}_attributes")
          send "#{model_name}_attributes=", attributes["#{model_name}_attributes"]
        end
      end

      model_names.each do |model_name|
        instance_variable_get("@#{model_name}").tap do |model|
          send "setup_#{model_name}", model if respond_to?("setup_#{model_name}")
          model.save
        end
      end

      model_names.each do |model_name|
        instance_variable_get("@#{model_name}").tap do |model|
          model.errors.each do |field, error|
            errors.add field, error
          end
        end
      end

      if errors.any?
        raise ActiveRecord::Rollback
      else
        true
      end
    end
  end

  private

  def self.model_names
    Array(@model_names)
  end

  def model_names
    self.class.model_names
  end
end
