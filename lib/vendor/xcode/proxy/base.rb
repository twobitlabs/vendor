module Vendor::XCode::Proxy

  class Base

    attr_accessor :id
    attr_accessor :parent
    attr_reader :attributes

    class << self

      # I don't know what the ID's are made up of in XCode,
      # so lets just generate a 24 character string.
      def generate_id
        (0...24).map { '%02X' % rand(256) }.join
      end

      def object_references
        @references || []
      end

      def reference(name)
        attribute = attribute_name(name)

        define_method name do
          value = @attributes[attribute]
          if value.kind_of?(Array)
            value.map { |id| @project.find_object(id) }
          else
            @project.find_object(value)
          end
        end

        @references ||= []
        @references << name
      end

      # References are stored in camel case in the project file
      def attribute_name(name)
        camelized = name.to_s.gsub(/[^\w]/, '').gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
        camelized[0].chr.downcase + camelized[1..-1]
      end

    end

    def initialize(options)
      @id = options[:id]
      @project = options[:project]
      @attributes = options[:attributes]

      @attributes['isa'] = self.class.name.split('::').last unless @attributes['isa']
    end

    def inspect
      properties = { "id" => @id }.merge(@attributes)

      # The class name contains the ISA (the type of the object)
      properties.delete("isa")

      # Always show the ID first
      keys = properties.keys.map(&:to_s)
      keys.delete("id")
      keys.unshift("id")

      "#<#{self.class.name} #{keys.map{ |key| "#{underscore(key)}: #{properties[key].inspect}" }.join(', ')}>"
    end

    def method_missing(v, *args)
      setting = v.to_s.match(/\=$/)
      name = self.class.attribute_name(v)

      if @attributes.has_key?(name)
        if setting
          write_attribute(name, args.first)
        else
          read_attribute(name)
        end
      else
        super
      end
    end

    def respond_to?(method)
      name = self.class.attribute_name(method)

      if @attributes.has_key?(name)
        true
      else
        super
      end
    end

    def write_attribute(name, value)
      @attributes[name.to_s] = value
    end

    def read_attribute(name)
      @attributes[name.to_s]
    end

    def to_ascii_plist
      @attributes.to_ascii_plist
    end

    def group?
      false
    end

    def file?
      false
    end

    private

      def after_initialize
        # Do nothing by default
      end

      # I miss active support...
      def underscore(string)
        string.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          downcase
      end

  end

end
