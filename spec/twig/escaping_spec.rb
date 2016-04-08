# describe 'twig_escape_filter' do
#
#   let (:env) {
#     Twig::Environment.new(double('Twig::LoaderInterface'))
#   }
#
#   #
#   # Convert a Unicode Codepoint to a literal UTF-8 character.
#   #
#   # @param int codepoint Unicode codepoint in hex notation
#   #
#   # @return string UTF-8 literal string
#   #
#   def codepoint_to_utf8(codepoint)
#     if codepoint < 0x80
#       return codepoint.chr
#     end
#
#     if codepoint < 0x800
#       return (codepoint >> 6 & 0x3f | 0xc0).chr + (codepoint & 0x3f | 0x80)
#     end
#
#     if codepoint < 0x10000
#       return (codepoint >> 12 & 0x0f | 0xe0).chr +
#         (codepoint >> 6 & 0x3f | 0x80).chr +
#         (codepoint & 0x3f | 0x80)
#     end
#
#     if codepoint < 0x110000
#       return (codepoint >> 18 & 0x07 | 0xf0).chr +
#         (codepoint >> 12 & 0x3f | 0x80).chr +
#         (codepoint >> 6 & 0x3f | 0x80).chr +
#         (codepoint & 0x3f | 0x80).chr
#     end
#
#     raise 'Codepoint requested outside of Unicode range'
#   end
#
#   it 'Html Escaping Converts Special Chars' do
#     {
#       '\'' => '&#039;',
#       '"' => '&quot;',
#       '<' => '&lt;',
#       '>' => '&gt;',
#       '&' => '&amp;'
#     }.each do |key, value|
#       expect(Twig::Runtime.twig_escape_filter(env, key, 'html')).to eq(value)
#     end
#   end
#
#   it 'Html Attribute Escaping Converts Special Chars' do
#     {
#       '\'' => '&#x27;',
#       # Characters beyond ASCII value 255 to unicode escape
#       'Ā' => '&#x0100;',
#       # Immune chars excluded
#       ',' => ',',
#       '.' => '.',
#       '-' => '-',
#       '_' => '_',
#       # Basic alnums excluded
#       'a' => 'a',
#       'A' => 'A',
#       'z' => 'z',
#       'Z' => 'Z',
#       '0' => '0',
#       '9' => '9',
#       # Basic control characters and null
#       "\r" => '&#x0D;',
#       "\n" => '&#x0A;',
#       "\t" => '&#x09;',
#       "\0" => '&#xFFFD;', # should use Unicode replacement char
#       # Encode chars as named entities where possible
#       '<' => '&lt;',
#       '>' => '&gt;',
#       '&' => '&amp;',
#       '"' => '&quot;',
#       # Encode spaces for quoteless attribute protection
#       ' ' => '&#x20;'
#     }.each do |key, value|
#       expect(Twig::Runtime.twig_escape_filter(env, key, 'html_attr')).to eq(value)
#     end
#   end
#
#   it 'Javascript Escaping Converts Special Chars' do
#     {
#       # HTML special chars - escape without exception to hex
#       '<' => '\\x3C',
#       '>' => '\\x3E',
#       '\'' => '\\x27',
#       '"' => '\\x22',
#       '&' => '\\x26',
#       # Characters beyond ASCII value 255 to unicode escape
#       'Ā' => '\\u0100',
#       # Immune chars excluded
#       ',' => ',',
#       '.' => '.',
#       '_' => '_',
#       # Basic alnums excluded
#       'a' => 'a',
#       'A' => 'A',
#       'z' => 'z',
#       'Z' => 'Z',
#       '0' => '0',
#       '9' => '9',
#       # Basic control characters and null
#       "\r" => '\\x0D',
#       "\n" => '\\x0A',
#       "\t" => '\\x09',
#       "\0" => '\\x00',
#       # Encode spaces for quoteless attribute protection
#       ' ' => '\\x20'
#     }.each do |key, value|
#       expect(Twig::Runtime.twig_escape_filter(env, key, 'js')).to eq(value)
#     end
#   end
#
#   it 'Javascript Escaping Returns String If Zero Length' do
#     expect(Twig::Runtime.twig_escape_filter(env, '', 'js')).to eq('')
#   end
#
#   it 'Javascript Escaping Returns String If Contains Only Digits' do
#     expect(Twig::Runtime.twig_escape_filter(env, '123', 'js')).to eq('123')
#   end
#
#   it 'Css Escaping Converts Special Chars' do
#     {
#       # HTML special chars - escape without exception to hex
#       '<' => '\\3C ',
#       '>' => '\\3E ',
#       '\'' => '\\27 ',
#       '"' => '\\22 ',
#       '&' => '\\26 ',
#       # Characters beyond ASCII value 255 to unicode escape
#       'Ā' => '\\100 ',
#       # Immune chars excluded
#       ',' => '\\2C ',
#       '.' => '\\2E ',
#       '_' => '\\5F ',
#       # Basic alnums excluded
#       'a' => 'a',
#       'A' => 'A',
#       'z' => 'z',
#       'Z' => 'Z',
#       '0' => '0',
#       '9' => '9',
#       # Basic control characters and null
#       "\r" => '\\D ',
#       "\n" => '\\A ',
#       "\t" => '\\9 ',
#       "\0" => '\\0 ',
#       # Encode spaces for quoteless attribute protection
#       ' ' => '\\20 '
#     }.each do |key, value|
#       expect(Twig::Runtime.twig_escape_filter(env, key, 'css')).to eq(value)
#     end
#   end
#
#   it 'Css Escaping Returns String If Zero Length' do
#     expect(Twig::Runtime.twig_escape_filter(env, '', 'css')).to eq('')
#   end
#
#   it 'Css Escaping Returns String If Contains Only Digits' do
#     expect(Twig::Runtime.twig_escape_filter(env, '123', 'css')).to eq('123')
#   end
#
#   it 'Url Escaping Converts Special Chars' do
#     {
#       # HTML special chars - escape without exception to percent encoding
#       '<' => '%3C',
#       '>' => '%3E',
#       '\'' => '%27',
#       '"' => '%22',
#       '&' => '%26',
#       # Characters beyond ASCII value 255 to hex sequence
#       'Ā' => '%C4%80',
#       # Punctuation and unreserved check
#       ',' => '%2C',
#       '.' => '.',
#       '_' => '_',
#       '-' => '-',
#       ':' => '%3A',
#       ';' => '%3B',
#       '!' => '%21',
#       # Basic alnums excluded
#       'a' => 'a',
#       'A' => 'A',
#       'z' => 'z',
#       'Z' => 'Z',
#       '0' => '0',
#       '9' => '9',
#       # Basic control characters and null
#       "\r" => '%0D',
#       "\n" => '%0A',
#       "\t" => '%09',
#       "\0" => '%00',
#       # PHP quirks from the past
#       ' ' => '%20',
#       '~' => '~',
#       '+' => '%2B'
#     }.each do |key, value|
#       expect(Twig::Runtime.twig_escape_filter(env, key, 'url')).to eq(value)
#     end
#   end
#
#   #
#   # Range tests to confirm escaped range of characters is within OWASP recommendation.
#   #
#
#   #
#   # Only testing the first few 2 ranges on this prot. function as that's all these
#   # other range tests require.
#   #
#   it 'Unicode Codepoint Conversion To Utf8' do
#     result = ''
#     [0x20, 0x7e, 0x799].each do |value|
#       result += codepoint_to_utf8(value)
#     end
#     expect(result).to eq(' ~ޙ')
#   end
#
#   it 'Javascript Escaping Escapes Owasp Recommended Ranges' do
#       immune = [',', '.', '_']
#       # Exceptions to escaping ranges
#       (0..0xfe).each do |chr|
#         if (chr >= 0x30 && chr <= 0x39) || (chr >= 0x41 && chr <= 0x5A) || (chr >= 0x61 && chr <= 0x7A)
#           literal = codepoint_to_utf8(chr)
#
#           expect(Twig::Runtime.twig_escape_filter(env, literal, 'js')).to eq(literal)
#         else
#           literal = codepoint_to_utf8(chr)
#
#           if (in_array(literal, immune))
#             expect(Twig::Runtime.twig_escape_filter(env, literal, 'js')).to eq(literal)
#
#           else
#             assertNotEquals(
#                 literal,
#                 twig_escape_filter(env, literal, 'js'),
#                 "literal should be escaped!")
#           end
#         end
#       end
#   end
#
#   it 'Html Attribute Escaping Escapes Owasp Recommended Ranges' do
#     immune = [',', '.', '-', '_']
#     # Exceptions to escaping ranges
#     (0..0xfe).each do |chr|
#       if (chr >= 0x30 && chr <= 0x39) || (chr >= 0x41 && chr <= 0x5a) || (chr >= 0x61 && chr <= 0x7a)
#
#         literal = codepoint_to_utf8(chr)
#
#         expect(Twig::Runtime.twig_escape_filter(env, literal, 'html_attr')).to eq(literal)
#       else
#         literal = codepoint_to_utf8(chr)
#
#         if immune.include?(literal)
#           expect(Twig::Runtime.twig_escape_filter(env, literal, 'html_attr')).to eq(literal)
#         else
#           assertNotEquals(
#               literal,
#               twig_escape_filter(env, literal, 'html_attr'),
#               "literal should be escaped!")
#         end
#       end
#     end
#   end
#
#   it 'Css Escaping Escapes Owasp Recommended Ranges' do
#     # CSS has no exceptions to escaping ranges
#     (0..0xFE).each do |chr|
#
#       if (chr >= 0x30 && chr <= 0x39) || (chr >= 0x41 && chr <= 0x5A) || (chr >= 0x61 && chr <= 0x7A)
#         literal = codepoint_to_utf8(chr)
#
#         expect(Twig::Runtime.twig_escape_filter(env, literal, 'css')).to eq(literal)
#       else
#         literal = codepoint_to_utf8(chr)
#
#         assertNotEquals(
#             literal,
#             twig_escape_filter(env, literal, 'css'),
#             "literal should be escaped!")
#       end
#     end
#   end
# end
