describe Twig::Environment do

  # it 'Render with no loader' do
  #   env = Twig::Environment.new
  #   expect{env.render('test')}.to raise_error(Twig::LogicError)
  # end
  #
  # it 'AutoescapeOption' do
  #   loader = Twig::Loader::Array.new({
  #     'html' => '{{ foo }} {{ foo }}',
  #     'js' => '{{ bar }} {{ bar }}',
  #   })
  #
  #   twig = Twig::Environment.new(loader, {
  #     'debug' => true,
  #     'cache' => false,
  #     'autoescape' => [self, 'escaping_strategy_callback']
  #   })
  #
  #   expect(twig.render('html', {'foo' => 'foo<br/ >'})).to eq('foo&lt;br/ &gt; foo&lt;br/ &gt;')
  #
  #   expect(twig.render('js', {'bar' => 'foo<br/ >'})).to eq('foo\x3Cbr\x2F\x20\x3E foo\x3Cbr\x2F\x20\x3E')
  # end

  # def escaping_strategy_callback(filename)
  #   filename
  # end
  #
  # it 'test_globals' do
  #   # globals can be added after calling getGlobals
  #   twig = Twig::Environment.new(double('Twig::Loader'))
  #
  #   twig.add_global('foo', 'foo')
  #
  #   twig.get_globals
  #
  #   twig.add_global('foo', 'bar')
  #
  #   globals = twig.get_globals
  #
  #   expect('bar', globals['foo'])
  #
  #   # globals can be modified after a template has been loaded
  #   twig = Twig::Environment.new(double('Twig::Loader'))
  #
  #   twig.add_global('foo', 'foo')
  #
  #   twig.get_globals
  #
  #   twig.load_template('index')
  #
  #   twig.add_global('foo', 'bar')
  #
  #   globals = twig.get_globals
  #
  #   expect(globals['foo']).to eq('bar')
  #
  #   # globals can be modified after extensions init
  #   twig = Twig::Environment.new(double('Twig::Loader'))
  #
  #   twig.add_global('foo', 'foo')
  #   twig.get_globals
  #   twig.get_functions
  #   twig.add_global('foo', 'bar')
  #
  #   globals = twig.get_globals
  #
  #   expect('bar', globals['foo'])
  #
  #   # globals can be modified after extensions and a template has been loaded
  #   twig = Twig::Environment.new(loader = Twig::Loader::Array.new({'index' => '{{foo}}'}))
  #
  #   twig.add_global('foo', 'foo')
  #
  #   twig.get_globals
  #
  #   twig.get_functions
  #
  #   twig.load_template('index')
  #
  #   twig.add_global('foo', 'bar')
  #
  #   globals = twig.get_globals
  #
  #   expect('bar', globals['foo'])
  #
  #   twig = Twig::Environment.new(loader)
  #
  #   twig.get_globals
  #
  #   twig.add_global('foo', 'bar')
  #
  #   template = twig.load_template('index')
  #
  #   expect('bar', template.render([]))
  #
  #   # /* to be uncomment in Twig 2.0
  #   # # globals cannot be added after a template has been loaded
  #   # twig = Twig::Environment.new(double('Twig::Loader'))
  #   #
  #   # twig.add_global('foo', 'foo')
  #   #
  #   # twig.get_globals
  #   #
  #   # twig.load_template('index')
  #   #
  #   # try {
  #   #     twig.add_global('bar', 'bar')
  #   #
  #   #     self.fail()
  #   #
  #   # end catch (LogicException $e) {
  #   #     self.assertFalse(array_key_exists('bar', twig.get_globals))
  #   #
  #   # end
  #   #
  #   # # globals cannot be added after extensions init
  #   # twig = Twig::Environment.new(double('Twig::Loader'))
  #   #
  #   # twig.add_global('foo', 'foo')
  #   #
  #   # twig.get_globals
  #   #
  #   # twig.get_functions
  #   #
  #   # try {
  #   #     twig.add_global('bar', 'bar')
  #   #
  #   #     self.fail()
  #   #
  #   # end catch (LogicException $e) {
  #   #     self.assertFalse(array_key_exists('bar', twig.get_globals))
  #   #
  #   # end
  #   #
  #   # # globals cannot be added after extensions and a template has been loaded
  #   # twig = Twig::Environment.new(double('Twig::Loader'))
  #   #
  #   # twig.add_global('foo', 'foo')
  #   #
  #   # twig.get_globals
  #   #
  #   # twig.get_functions
  #   #
  #   # twig.load_template('index')
  #   #
  #   # try {
  #   #     twig.add_global('bar', 'bar')
  #   #
  #   #     self.fail()
  #   #
  #   # end catch (LogicException $e) {
  #   #     self.assertFalse(array_key_exists('bar', twig.get_globals))
  #   #
  #   # end
  #   #
  #   # # test adding globals after a template has been loaded without call to getGlobals
  #   # twig = Twig::Environment.new(double('Twig::Loader'))
  #   #
  #   # twig.load_template('index')
  #   #
  #   # try {
  #   #     twig.add_global('bar', 'bar')
  #   #
  #   #     self.fail()
  #   #
  #   # end catch (LogicException $e) {
  #   #     self.assertFalse(array_key_exists('bar', twig.get_globals))
  #   #
  #   # end
  #   # */
  # end
  #
  # it 'Compile Source Inlines Source' do
  #   twig = Twig::Environment.new(double('Twig::Loader'))
  #
  #   compiled = twig.compile_source("<? */*foo*/ ?>\r\nbar\n", 'index')
  #
  #   expect(compiled).to include("/* <? *//* *foo*//*  ?>*/\n/* bar*/\n/* */\n")
  #   expect(compiled).not_to include('/**')
  # end
  #
  # it 'Extensions Are Not Initialized When Rendering A Compiled Template' do
  #   dir = sys_get_temp_dir()+'/twig'
  #   cache = Twig::Cache::Filesystem.new(dir)
  #
  #   options = { 'cache' => cache, 'auto_reload' => false, 'debug' => false }
  #
  #   # force compilation
  #   twig = Twig::Environment.new(loader = Twig::Loader::Array.new({'index' => '{{ foo }}'}), options)
  #
  #   key = cache.generateKey('index', twig.getTemplateClass('index'))
  #
  #   cache.write(key, twig.compile_source('{{ foo }}', 'index'))
  #
  #   # check that extensions won't be initialized when rendering a template that is already in the cache
  #   twig = double('Twig::Environment')
  #   twig.set_constructor_args([loader, options])
  #   twig.setMethods(['initExtensions'])
  #
  #   # twig.expects(self.never()).method('initExtensions')
  #
  #   # render template
  #   output = twig.render('index', { 'foo' => 'bar' })
  #
  #   expect('bar', output)
  #
  #   unlink(key)
  # end

  # def testAutoReloadCacheMiss
  #   templateName = __FUNCTION__
  #   templateContent = __FUNCTION__
  #
  #   cache = double('Twig_CacheInterface')
  #
  #   loader = self.getMockLoader(templateName, templateContent)
  #
  #   twig = Twig::Environment.new(loader, {'cache' => cache, 'auto_reload' => true, 'debug' => false})
  #
  #
  #   # Cache miss: getTimestamp returns 0 and as a result the load() is
  #   # skipped.
  #   cache.expects(self.once())
  #     .method('generateKey')
  #     .will(self.returnValue('key'))
  #
  #   cache.expects(self.once())
  #     .method('getTimestamp')
  #     .will(self.returnValue(0))
  #
  #   loader.expects(self.never())
  #     .method('isFresh')
  #
  #   cache.expects(self.never())
  #     .method('load')
  #
  #   twig.load_template(templateName)
  # end

  # def testAutoReloadCacheHit
  #   templateName = __FUNCTION__;
  #   templateContent = __FUNCTION__;
  #
  #   cache = double('Twig_CacheInterface')
  #
  #   loader = self.getMockLoader(templateName, templateContent)
  #
  #   twig = Twig::Environment.new(loader, { 'cache' => cache, 'auto_reload' => true, 'debug' => false })
  #
  #   now = Time.now
  #
  #   # Cache hit: getTimestamp returns something > extension timestamps and
  #   # the loader returns true for isFresh().
  #   cache.expects(self.once())
  #     .method('generateKey')
  #     .will(self.returnValue('key'))
  #
  #   cache.expects(self.once())
  #     .method('getTimestamp')
  #     .will(self.returnValue(now))
  #
  #   loader.expects(self.once())
  #     .method('isFresh')
  #     .will(self.returnValue(true))
  #
  #   cache.expects(self.once())
  #     .method('load')
  #
  #   twig.load_template(templateName)
  #
  # end

  # def testAutoReloadOutdatedCacheHit
  #   templateName = __FUNCTION__;
  #   templateContent = __FUNCTION__;
  #
  #   cache = double('Twig_CacheInterface')
  #
  #   loader = self.getMockLoader(templateName, templateContent)
  #
  #   twig = Twig::Environment.new(loader, {'cache' => cache, 'auto_reload' => true, 'debug' => false})
  #
  #   now = Time.now
  #
  #   cache.expects(self.once())
  #     .method('generateKey')
  #     .will(self.returnValue('key'))
  #
  #   cache.expects(self.once())
  #     .method('getTimestamp')
  #     .will(self.returnValue(now))
  #
  #   loader.expects(self.once())
  #     .method('isFresh')
  #     .will(self.returnValue(false))
  #
  #   cache.expects(self.never())
  #     .method('load')
  #
  #   twig.load_template(templateName)
  # end

  # class Twig::Extension::WithGlobals
  #   include Twig::Extension
  #
  #   def get_globals
  #     {
  #       'foo_global' => 'foo_global'
  #     }
  #   end
  #
  #   def get_name
  #     'environment_test'
  #   end
  # end

  # it 'addExtension' do
  #   twig = Twig::Environment.new(double('Twig::Loader'))
  #   twig.add_extension(Twig::Extension::WithGlobals.new)
  #
  #   expect(twig.get_tags.key?('test')).to eq(true)
  #   expect(twig.get_filters.key?('foo_filter')).to eq(true)
  #   expect(twig.get_functions.key?('foo_function')).to eq(true)
  #   expect(twig.get_tests.key?('foo_test')).to eq(true)
  #   expect(twig.get_unary_operators.key?('foo_unary')).to eq(true)
  #   expect(twig.get_binary_operators.key?('foo_binary')).to eq(true)
  #   expect(twig.get_globals.key?('foo_global')).to eq(true)
  #
  #   visitors = twig.get_node_visitors
  #
  #   expect(visitors[2].class).to eq(Twig::NodeVisitor)
  # end

  # it 'AddExtensionWithDeprecatedGetGlobals' do
  #   twig = Twig::Environment.new(double('Twig::Loader'))
  #
  #   twig.add_extension(Twig::Extension::WithGlobals.new)
  #
  #   @deprecations = []
  #
  #   set_error_handler([self, 'handleError'])
  #
  #   expect(twig.get_globals.key?('foo_global')).to eq(true)
  #
  #   self.assertCount(1, @deprecations)
  #
  #   self.assertContains('Defining the getGlobals() method in the "environment_test" extension is deprecated', @deprecations[0])
  #
  #   restore_error_handler()
  # end

    # /**
    #  * @group legacy
    #  */
    # def testRemoveExtension
    #     twig = Twig::Environment.new(double('Twig::Loader'))
    #
    #     twig.add_extension(Twig::Extension.new)
    #
    #     twig.removeExtension('environment_test')
    #
    #     self.assertFalse(array_key_exists('test', twig.get_tags)
    #
    #     self.assertFalse(array_key_exists('foo_filter', twig.get_filters))
    #
    #     self.assertFalse(array_key_exists('foo_function', twig.get_functions))
    #
    #     self.assertFalse(array_key_exists('foo_test', twig.get_tests))
    #
    #     self.assertFalse(array_key_exists('foo_unary', twig.get_unary_operators))
    #
    #     self.assertFalse(array_key_exists('foo_binary', twig.get_binary_operators))
    #
    #     self.assertFalse(array_key_exists('foo_global', twig.get_globals))
    #
    #     self.assertCount(2, twig.get_nodeVisitors())
    # end

  # def testAddMockExtension
  #   extension = double('Twig::Extension')
  #
  #   extension.expects(self.once())
  #     .method('get_name')
  #     .will(self.returnValue('mock'))
  #
  #   loader = Twig::Loader::Array.new(array('page' => 'hey'))
  #
  #   twig = Twig::Environment.new(loader)
  #
  #   twig.add_extension(extension)
  #
  #   self.assertInstanceOf('Twig::Extension', twig.getExtension('mock'))
  #
  #   self.assertTrue(twig.isTemplateFresh('page', Time.now))
  # end
  #
  # def testInitRuntimeWithAnExtensionUsingInitRuntimeNoDeprecation()
  #   twig = Twig::Environment.new(double('Twig::Loader'))
  #
  #   twig.add_extension(Twig::ExtensionWithoutDeprecationInitRuntime.new)
  #
  #   twig.init_runtime
  # end
  #
  # class Twig::ExtensionWithDeprecationInitRuntime
  #   include Twig::Extension
  #
  #   def init_runtime(env)
  #   end
  #
  #   def get_name
  #     'with_deprecation'
  #   end
  # end
  #
  # def testInitRuntimeWithAnExtensionUsingInitRuntimeDeprecation
  #   twig = Twig::Environment.new(double('Twig::Loader'))
  #
  #   twig.add_extension(Twig::ExtensionWithDeprecationInitRuntime.new)
  #
  #   @deprecations = []
  #
  #   set_error_handler([self, 'handleError'])
  #
  #   twig.init_runtime()
  #
  #   self.assertCount(1, @deprecations)
  #
  #   self.assertContains('Defining the init_runtime() method in the "with_deprecation" extension is deprecated.', @deprecations[0])
  #
  #   restore_error_handler()
  # end
  #
  # def handleError(type, msg)
  #   @deprecations << msg
  # end
  #
  # it 'OverrideExtension' do
  #   twig = Twig::Environment.new(double('Twig::Loader'))
  #
  #   twig.add_extension(Twig::ExtensionWithDeprecationInitRuntime.new)
  #
  #   @deprecations = []
  #
  #   set_error_handler([self, 'handleError'])
  #
  #   twig.add_extension(Twig::Extension.new)
  #
  #   twig.add_extension(Twig::Extension.new)
  #
  #   self.assertCount(1, @deprecations)
  #
  #   self.assertContains('The possibility to register the same extension twice', @deprecations[0])
  #
  #   restore_error_handler()
  # end
  #
  # def getMockLoader(templateName, templateContent)
  #   loader = double('Twig::Loader')
  #
  #   loader.expects(self.any())
  #     .method('getSource')
  #     .with(templateName)
  #     .will(self.returnValue(templateContent))
  #
  #   loader.expects(self.any())
  #     .method('getCacheKey')
  #     .with(templateName)
  #     .will(self.returnValue(templateName))
  #
  #   return loader
  # end
end

# class Twig_Tests_EnvironmentTest_Extension
#   include Twig::Extension
#
#   def get_token_parsers
#     [ Twig::TokenParserTest.new ]
#   end
#
#   def get_node_visitors
#     [ Twig::NodeVisitorTest.new]
#   end
#
#   def get_filters
#     [Twig::SimpleFilter.new('foo_filter', 'foo_filter')]
#   end
#
#   def get_tests
#     [Twig::SimpleTest.new('foo_test', 'foo_test')]
#   end
#
#   def get_functions
#     [Twig::SimpleFunction.new('foo_function', 'foo_function')]
#   end
#
#   def get_operators
#     [
#       { 'foo_unary' => [] },
#       { 'foo_binary' => [] }
#     ]
#   end
#
#   def get_globals
#     { 'foo_global' => 'foo_global' }
#   end
#
#   def get_name
#     'environment_test'
#   end
# end
#
# class Twig::TokenParserTest < Twig::TokenParser
#   def parse(token)
#   end
#
#   def tag
#     return 'test'
#   end
# end
#
# class Twig::NodeVisitorTest < Twig::NodeVisitor
#   def enter_Node(node, env)
#     node
#   end
#
#   def leave_Node(node, env)
#     node
#   end
#
#   def get_priority
#     0
#   end
# end
#
# class Twig::ExtensionWithoutDeprecationInitRuntime < Twig::Extension
#   def init_runtime(env)
#   end
#
#   def get_name
#     'without_deprecation'
#   end
# end
