module Rarff
  class Attribute
    attr_accessor :name

    def initialize(name='', type='')
      @name = name

      @type_is_nominal = false
      self.type= type
    end

    def nominal?
      @type_is_nominal
    end

    def type=(type)
      @type = type
      convert_nominal!
      @type.sub!(/\w+/) {|m| m.upcase} unless nominal?
    end

    def type
      @type
    end


    # Convert string representation of nominal type to array, if necessary
    # TODO: This might falsely trigger on wacky date formats.
    def convert_nominal!
      if @type =~ /^\s*\{.*(\,.*)+\}\s*$/
        @type_is_nominal = true
        # Example format: "{nom1,nom2, nom3, nom4,nom5 } "
        # Split on '{'  ','  or  '}' and remove any inner ''s
        @type = @type.gsub(/^\s*\{\s*/, '').gsub(/\s*\}\s*$/, '').split(/\s*\,\s*/).map! { |el| el.gsub(/^\s*\'(.*)\'\s*$/, "\\1")}
      end
    end


    def add_nominal_value(str)
      if @type_is_nominal
        @type = Array.new
      end

      @type << str
    end


    def to_arff
      if @type_is_nominal
        ATTRIBUTE_MARKER + " #@name #{@type.join(',')}"
      else
        ATTRIBUTE_MARKER + " #@name #@type"
      end
    end


    def to_s
      to_arff
    end

  end
end
