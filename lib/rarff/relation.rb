module Rarff
  class Relation
    attr_accessor :name, :attributes, :instances, :comments


    def initialize(name='')
      @name = name
      @attributes = Array.new
      @instances = Array.new
      @comments = Array.new
    end

    def parse(arg)
      if arg.is_a? String
        arff_io = StringIO.new(arg)
      elsif arg.is_a?(IO) || arg.is_a?(StringIO)
        arff_io = arg
      else
        raise ArgumentError "Parse takes either an I/O object or a string"
      end

      in_data_section = false

      # TODO: Doesn't handle commas in quoted attributes.
      arff_io.each { |line|
        next if line =~ /^\s*$/
        line.chomp!
        next if line.my_scan(/^\s*#{COMMENT_MARKER}/) { @comments << Comment.new(line.slice(1..-1), arff_io.lineno) }
        next if line.my_scan(/^\s*#{RELATION_MARKER}\s*(.*)\s*$/i) { |name| @name = name }
        next if line.my_scan(/^\s*#{ATTRIBUTE_MARKER}\s*([^\s]*)\s+(.*)\s*$/i) { |name, type|
          @attributes.push(Attribute.new(name, type))
        }
        next if line.my_scan(/^\s*#{DATA_MARKER}/i) { in_data_section = true }
        next if !in_data_section ## Below is data section handling
                                 #			next if line.gsub(/^\s*(.*)\s*$/, "\\1").my_scan(/^\s*#{SPARSE_ARFF_BEGIN}(.*)#{SPARSE_ARFF_END}\s*$/) { |data|
        next if line.gsub(/^\s*(.*)\s*$/, "\\1").my_scan(/^#{ESC_SPARSE_ARFF_BEGIN}(.*)#{ESC_SPARSE_ARFF_END}$/) { |data|
          # Sparse ARFF
          # TODO: Factor duplication with non-sparse data below
          raw_instance = process_sparse_row(data.first)
          @instances << type_convert_row(raw_instance)
        }
        next if line.my_scan(/^\s*(.*)\s*$/) { |data|
          raw_instance = process_normal_row(data)
          @instances << type_convert_row(raw_instance)
        }
      }
      #create_attributes()


    end

    #TODO refactor this method. don't need another iteration through the instance
    def process_normal_row(data)
      data.first.split(/,\s*/).map! { |field|
        # Remove outer single quotes on strings, if any ('foo bar' --> foo bar)
        field.gsub(/^\s*\'(.*)\'\s*$/, "\\1")
      }
    end

    def type_convert_row(arr)

      idx = 0
      arr.map! { |element|
        if @attributes[idx].nominal?
          unless element.eql?('?') || @attributes[idx].type.include?(element)
            raise ArgumentError, "Instance element #{idx} - '#{element.to_s}' - was not valid for this attribute (#{@attributes[idx].name})\n Valid options - #{@attributes[idx].type.inspect}"
          end
          out = element
        else
          case @attributes[idx].type
            when ATTRIBUTE_NUMERIC
              out = element.to_f
            when ATTRIBUTE_REAL
              out = element.to_f
            when ATTRIBUTE_INTEGER
              out = element.to_i
            when ATTRIBUTE_STRING
              out = element
            when ATTRIBUTE_DATE
              out = element
            #Date.new(element) # TODO fix this
            when /#{ATTRIBUTE_DATE}\s['"][^'"]*['"]/
              out = element #TODO fix this
            else
              raise ArgumentError, "Attribute type unknown - #{@attributes[idx].type}"
          end
        end
        idx+=1
        out
      }
      arr
    end


    def process_sparse_row(str)
      arr = Array.new(@attributes.size, 0)
      str.gsub(/^\s*\{(.*)\}\s*$/, "\\1").split(/\s*\,\s*/).map { |pr|
        pra = pr.split(/\s/)
        arr[pra[0].to_i] = pra[1]
      }
      arr
    end

    def instances=(instances)
      @instances = instances
    end

    def to_arff
      RELATION_MARKER + " #@name\n" +
          @attributes.map { |attr| attr.to_arff }.join("\n") +
          "\n" +
          DATA_MARKER + "\n" +
          @instances.map { |inst|
            inst.map_with_index { |col, i|
              # Quote strings with spaces.
              # TODO: Doesn't handle cases in which strings already contain
              # quotes or are already quoted.
              if @attributes[i].type =~ /^#{ATTRIBUTE_STRING}$/i
                if col =~ /\s+/
                  col = "'" + col + "'"
                end
              elsif @attributes[i].type =~ /^#{ATTRIBUTE_DATE}/i ## Hack comparison. Ugh.
                col = '"' + col + '"'
              end
              col
            }.join(', ')
          }.join("\n")
    end

    def to_s
      to_arff
    end
  end
end