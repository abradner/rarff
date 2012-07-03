# See the README file for more information.

require 'test/unit'
require 'rarff'
require 'csv'

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

    instances = [[1.4, 'foo bar', 5, 'baz', "1900-08-08 12:12:12"],
                 [20.9, 'ruby', 46, 'rocks', "2005-10-23 12:12:12"],
                 [20.9, 'ruby', 46, 'rocks', "2001-02-19 12:12:12"],
                 [68.1, 'stuff', 728, 'is cool', "1974-02-10 12:12:12"]]

    rel = Rarff::Relation.new('MyCoolRelation')
    rel.attributes << Rarff::Attribute.new("Attr0", Rarff::ATTRIBUTE_NUMERIC)
    rel.attributes << Rarff::Attribute.new('subject', Rarff::ATTRIBUTE_STRING)
    rel.attributes << Rarff::Attribute.new('Attr2', Rarff::ATTRIBUTE_NUMERIC)
    rel.attributes << Rarff::Attribute.new('Attr3', Rarff::ATTRIBUTE_STRING)
    rel.attributes << Rarff::Attribute.new('birthday', Rarff::ATTRIBUTE_DATE + ' "yyyy-MM-dd HH:mm:ss"')

    rel.instances = instances

#		puts "rel.to_arff:\n(\n#{rel.to_arff}\n)\n"
    assert_equal(arff_file_str, rel.to_arff, "Arff creation test failed.")
  end


  # Test parsing of an arff file.
  def test_arff_parse
    in_file = './test/test_arff.arff'
    rel = Rarff::Relation.new
    rel.parse(File.open(in_file))

    assert_equal(3.2, rel.instances[2][1])
    assert_equal('Iris-setosa', rel.instances[7][4])
  end


  # Test parsing of sparse ARFF format
  def test_sparse_arff_parse
    in_file = './test/test_sparse_arff.arff'
    rel = Rarff::Relation.new
    rel.parse(File.open(in_file))

    assert_equal(13, rel.instances[0].size)
    assert_equal(0, rel.instances[0][1])
    assert_equal(7, rel.instances[0][3])
    assert_equal(2.4, rel.instances[1][1])
    assert_equal(0, rel.instances[1][2])
    assert_equal(19, rel.instances[1][12])
    assert_equal(6, rel.instances[2][6])
    assert_equal(0, rel.instances[3][12])
#		puts "\n\nARFF: (\n#{rel.to_arff}\n)"
  end

  def test_case_insensitivity
    in_file = './test/test_case_arff.arff'
    rel = Rarff::Relation.new
    rel.parse(File.open(in_file))

    assert_equal(5, rel.attributes.count, "Incorrect number of attributes found")

  end

  def test_attributes_keep_their_names
    in_file = './test/test_case_arff.arff'
    rel = Rarff::Relation.new
    rel.parse(File.open(in_file))

    assert_equal('left-weight', rel.attributes[0].name, "first attribute not as expected")
    assert_equal('class', rel.attributes[4].name, "last attribute not as expected")

  end

  def test_all_comments_stored
    in_file = './test/test_comments_arff.arff'
    in_comments_csv = './test/test_comments_raw.csv'

    comments = []

    CSV.open(in_comments_csv, 'r') do |row|
      comments << Rarff::Comment.new(row[0].to_s,row[1].to_i)
    end

    rel = Rarff::Relation.new
    in_file_contents = File.open(in_file)
    rel.parse(in_file_contents)

    assert_equal(comments.length, rel.comments.length, "Some comments not stored or extra comments stored")
    assert_equal(comments, rel.comments, "Comments / lines differ")
  end

  def test_input_to_output_match
    #todo
    #in_file = './test/test_comments_arff.arff'
    #rel = Rarff::Relation.new
    #
    #in_file_contents = File.open(in_file)
    #rel.parse(in_file_contents)
    #
    #assert_equal(in_file_contents, rel.to_arff, "Arff input and output don't match'.")

  end
end

