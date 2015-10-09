module Setup
  class Validator
    include CenitScoped

    BuildInDataType.regist(self).referenced_by(:name)

    Setup::Models.exclude_actions_for self

    field :name, type: String

    validates_uniqueness_of :name

    before_save :validates_configuration

    def validates_configuration
      errors.blank?
    end

    def validate_file_record(data)
      fail NotImplementedError
    end

    def data_format
      nil
    end

    def content_type
      nil
    end
  end
end