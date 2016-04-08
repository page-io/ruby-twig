# describe Twig::AutoloaderTest extends PHPUnit_Framework_TestCase
# {
#     /**
#      * @group legacy
#      */
#     def testAutoload()
#     {
#         $this->assertFalse(class_exists('FooBarFoo'), '->autoload() does not try to load classes that does not begin with Twig')
#
#
#         $autoloader = new Twig_Autoloader()
#
#         $this->assertNull($autoloader->autoload('Foo'), '->autoload() returns false if it is not able to load a class')
#
#     }
# }
