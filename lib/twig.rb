require "twig/version"

require 'twig/environment'
require 'twig/compiler'
require 'twig/error'
require 'twig/expression_parser'
require 'twig/extension'
require 'twig/lexer'
require 'twig/loader_interface'
require 'twig/logic_exception'
require 'twig/markup'
require 'twig/node'
require 'twig/node_traverser'
require 'twig/parser_interface'
require 'twig/parser'
require 'twig/runtime'
require 'twig/simple_filter'
require 'twig/simple_function'
require 'twig/simple_test'
require 'twig/template'
require 'twig/token_parser_broker'
require 'twig/token_parser_interface'
require 'twig/token_parser'
require 'twig/token_stream'
require 'twig/token'

require 'twig/cache/null'

require 'twig/node/output'
require 'twig/node/auto_escaper'
require 'twig/node/block'
require 'twig/node/block_reference'
require 'twig/node/body'
require 'twig/node/check_security'
require 'twig/node/do'
require 'twig/node/expression'
require 'twig/node/flush'
require 'twig/node/for'
require 'twig/node/for_loop'
require 'twig/node/if'
require 'twig/node/import'
require 'twig/node/include'
require 'twig/node/macro'
require 'twig/node/module'
require 'twig/node/print'
require 'twig/node/sandbox'
require 'twig/node/sandboxed_print'
require 'twig/node/set'
require 'twig/node/set_temp'
require 'twig/node/spaceless'
require 'twig/node/text'

require 'twig/node/expression/name'
require 'twig/node/expression/array'
require 'twig/node/expression/assign_name'
require 'twig/node/expression/binary'
require 'twig/node/expression/block_reference'
require 'twig/node/expression/call'
require 'twig/node/expression/conditional'
require 'twig/node/expression/constant'
require 'twig/node/expression/extension_reference'
require 'twig/node/expression/filter'
require 'twig/node/expression/function'
require 'twig/node/expression/get_attr'
require 'twig/node/expression/hash'
require 'twig/node/expression/method_call'
require 'twig/node/expression/parent'
require 'twig/node/expression/temp_name'
require 'twig/node/expression/test'
require 'twig/node/expression/unary'
require 'twig/node/expression/filter/default'
require 'twig/node/expression/test/constant'
require 'twig/node/expression/test/defined'
require 'twig/node/expression/test/divisibleby'
require 'twig/node/expression/test/even'
require 'twig/node/expression/test/null'
require 'twig/node/expression/test/odd'
require 'twig/node/expression/test/sameas'
require 'twig/node/expression/binary/add'
require 'twig/node/expression/binary/and'
require 'twig/node/expression/binary/bitwise_and'
require 'twig/node/expression/binary/bitwise_or'
require 'twig/node/expression/binary/bitwise_xor'
require 'twig/node/expression/binary/concat'
require 'twig/node/expression/binary/div'
require 'twig/node/expression/binary/ends_with'
require 'twig/node/expression/binary/equal'
require 'twig/node/expression/binary/floor_div'
require 'twig/node/expression/binary/greater'
require 'twig/node/expression/binary/greater_equal'
require 'twig/node/expression/binary/in'
require 'twig/node/expression/binary/less'
require 'twig/node/expression/binary/less_equal'
require 'twig/node/expression/binary/matches'
require 'twig/node/expression/binary/mod'
require 'twig/node/expression/binary/mul'
require 'twig/node/expression/binary/not_equal'
require 'twig/node/expression/binary/not_in'
require 'twig/node/expression/binary/or'
require 'twig/node/expression/binary/power'
require 'twig/node/expression/binary/range'
require 'twig/node/expression/binary/starts_with'
require 'twig/node/expression/binary/sub'
require 'twig/node/expression/unary/neg'
require 'twig/node/expression/unary/not'
require 'twig/node/expression/unary/pos'

Dir["#{__dir__}/twig/error/*.rb"].each { |f| require f }
Dir["#{__dir__}/twig/extension/*.rb"].each { |f| require f }
Dir["#{__dir__}/twig/loader/*.rb"].each { |f| require f }
# Dir["#{__dir__}/twig/node/**/*.rb"].each { |f| require f }
# Dir["#{__dir__}/twig/node/expression/*.rb"].each { |f| require f }
Dir["#{__dir__}/twig/token_parser/*.rb"].each { |f| require f }
Dir["#{__dir__}/twig/sandbox/*.rb"].each { |f| require f }

if defined? Tilt
  require 'tilt/twig_template2'
  Tilt.register Tilt::TwigTemplate2, 'twig'
  # Tilt.register_lazy 'Tilt::TwigTemplate', 'tilt/twig_template', 'twig'
end
