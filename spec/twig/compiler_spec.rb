# describe Twig::Compiler
#
#     it 'ReprNumericValueWithLocale'
#
#         compiler = new Twig::Compiler(Twig::Environment.new(double('Twig_LoaderInterface')))
#
#         locale = setlocale(LC_NUMERIC, 0)
#
#         if (false === $locale)
#             $this->markTestSkipped('Your platform does not support locales.')
#         end
#
#         $required_locales = ['fr_FR.UTF-8', 'fr_FR.UTF8', 'fr_FR.utf-8', 'fr_FR.utf8', 'French_France.1252']
#
#         if (false === setlocale(LC_NUMERIC, $required_locales)) {
#             $this->markTestSkipped('Could not set any of required locales: '.implode(', ', $required_locales))
#
#         }
#
#         expect('1.2', compiler->repr(1.2)->getSource())
#
#         $this->assertContains('fr', strtolower(setlocale(LC_NUMERIC, 0)))
#
#
#         setlocale(LC_NUMERIC, $locale)
#
#     end
# end
