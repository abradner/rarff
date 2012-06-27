# See the README file for more information.

require 'test/unit'
require 'rarff'

class TestArffLib < Test::Unit::TestCase

	# Test creation of an arff file string.
    def test_arff_creation

    arff_file_str = <<-END_OF_ARFF_FILE
@RELATION MyCoolRelation
@ATTRIBUTE Attr0 NUMERIC
@ATTRIBUTE subject STRING
@ATTRIBUTE Attr2 NUMERIC
@ATTRIBUTE Attr3 STRING
@ATTRIBUTE birthday DATE "yyyy-MM-dd HH:mm:ss"
@DATA
1.4, 'foo bar', 5, baz, "1900-08-08 12:12:12"
20.9, ruby, 46, rocks, "2005-10-23 12:12:12"
20.9, ruby, 46, rocks, "2001-02-19 12:12:12"
68.1, stuff, 728, 'is cool', "1974-02-10 12:12:12"
END_OF_ARFF_FILE

        arff_file_str.gsub!(/\n$/, '')

        instances = [ [1.4, 'foo bar', 5, 'baz', "1900-08-08 12:12:12"],
	        		[20.9, 'ruby', 46, 'rocks', "2005-10-23 12:12:12"],
		        	[20.9, 'ruby', 46, 'rocks', "2001-02-19 12:12:12"],
        			[68.1, 'stuff', 728, 'is cool', "1974-02-10 12:12:12"]]

        rel = Rarff::Relation.new('MyCoolRelation')
        rel.instances = instances
        rel.attributes[1].name = 'subject'
        rel.attributes[4].name = 'birthday'
        rel.attributes[4].type = 'DATE "yyyy-MM-dd HH:mm:ss"'

#		puts "rel.to_arff:\n(\n#{rel.to_arff}\n)\n"
        assert_equal(rel.to_arff, arff_file_str, "Arff creation test failed.")
    end


	# Test parsing of an arff file.
	def test_arff_parse
		in_file = './test_arff.arff'
		rel = Rarff::Relation.new
		rel.parse(File.open(in_file).read)

		assert_equal(rel.instances[2][1], 3.2)
		assert_equal(rel.instances[7][4], 'Iris-setosa')
	end


	# Test parsing of sparse ARFF format
    def test_sparse_arff_parse
		in_file = './test_sparse_arff.arff'
		rel = Rarff::Relation.new
		rel.parse(File.open(in_file).read)

		assert_equal(rel.instances[0].size, 13)
		assert_equal(rel.instances[0][1], 0)
		assert_equal(rel.instances[0][3], 7)
		assert_equal(rel.instances[1][1], 2.4)
		assert_equal(rel.instances[1][2], 0)
		assert_equal(rel.instances[1][12], 19)
		assert_equal(rel.instances[2][6], 6)
		assert_equal(rel.instances[3][12], 0)
#		puts "\n\nARFF: (\n#{rel.to_arff}\n)"
	end
end



