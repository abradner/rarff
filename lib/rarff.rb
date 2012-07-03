# = rarff

# This is the top-level include file for rarff. See the README file for
# details.

################################################################################


module Rarff
  require "stringio"
  require "rarff/core_ext/string"
  require "rarff/core_ext/enumerable"
  require "rarff/constants"
  Comment = Struct.new(:text,:row)
  require "rarff/attribute"
  require "rarff/relation"

end # module Rarff

################################################################################

if $0 == __FILE__

  exit unless ARGV[0]
  in_file = ARGV[0]
  contents = ''

  contents = File.open(in_file).read

  rel = Rarff::Relation.new
  rel.parse(contents)

  puts '='*80
  puts '='*80
  puts "ARFF:"
  puts rel

end

################################################################################


