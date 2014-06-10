module Hub
	class Option
	  include Mongoid::Document
	  #include Mongoid::Attributes::Dynamic
	  include Mongoid::Timestamps

	  belongs_to :variant, class_name: 'Hub::Variant'
    belongs_to :line_item, class_name: 'Hub::LineItem'

    field :option_type, type: String
	  field :option_value, type: String

	  index({ starred: 1 })
	end
end