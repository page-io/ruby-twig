module Twig

  class Environment

    # The base template class for compiled templates.
    attr_accessor :base_template_class

    # Constructor.
    #
    # Available options:
    #
    #  # debug: When set to true, it automatically set "auto_reload" to true as
    #           well (default to false).
    #
    #  # charset: The charset used by the templates (default to UTF-8).
    #
    #  # base_template_class: The base template class to use for generated  templates (default to Twig::Template).
    #
    #  # cache: An absolute path where to store the compiled templates,
    #           a Twig::Cache implementation,
    #           or false to disable compilation cache (default).
    #
    #  # auto_reload: Whether to reload the template if the original source changed.
    #                 If you don't provide the auto_reload option, it will be
    #                 determined automatically based on the debug value.
    #
    #  # strict_variables: Whether to ignore invalid variables in templates
    #                      (default to false).
    #
    #  # autoescape: Whether to enable auto-escaping (default to html):
    #                 * false: disable auto-escaping
    #                 * true: equivalent to html
    #                 * html, js: set the autoescaping to one of the supported strategies
    #                 * filename: set the autoescaping strategy based on the template filename extension
    #                 * lamda callback: a lambda that receives the template "filename" and returns an escaping strategy
    #
    #  # optimizations: A flag that indicates which optimizations to apply
    #                   (default to -1 which means that all optimizations are enabled;
    #                   set it to 0 to disable).
    #
    # @param loader [Twig::Loader] A Twig::Loader instance
    # @param options [Array]  options An array of options
    def initialize(loader, options = {})
      # unless loader
      #   raise ArgumentError.new('loader can not be nil.')
      # end
      @loader = loader

      # protected $debug;
      # protected $autoReload;
      # protected cache;
      # protected $lexer;
      # protected $parser;
      # protected compiler;
      # protected $baseTemplateClass;
      @extensions = {}
      # protected $parsers;
      @visitors = []
      @filters = {}
      # protected tests;
      # protected functions;
      # protected $globals;
      # protected $runtimeInitialized = false;
      @extension_initialized = false
      @loaded_templates = {}
      # protected $strictVariables;
      # protected $unaryOperators;
      # protected $binaryOperators;
      # protected $templateClassPrefix = '__TwigTemplate_';
      @function_callbacks = []
      @filter_callbacks = []
      # private $originalCache;
      # private $bcWriteCacheFile = false;
      # private $bcGetCacheFilename = false;
      @last_modified_extension = 0

      # else
      # end
      options = {
        'debug' => false,
        'charset' => 'UTF-8',
        'base_template_class' => 'Twig::Template',
        'strict_variables' => false,
        'autoescape' => 'html',
        'cache' => false,
        'auto_reload' => nil,
        'optimizations' => -1
      }.merge(options)
      @debug = !!options['debug']
      @charset = options['charset'].upcase
      @base_template_class = options['base_template_class']
      # @auto_reload = nil == options['auto_reload'] ? @debug : (bool) options['auto_reload'];
      @strict_variables = options['strict_variables']
      # set_cache(options['cache'])
      add_extension(Twig::Extension::Core.new)
      add_extension(Twig::Extension::Escaper.new(options['autoescape']))
      add_extension(Twig::Extension::Optimizer.new(options['optimizations']))
      @staging = Twig::Extension::Staging.new

      # # For BC
      # if (is_string(@original_cache)) {
      #     $r = new ReflectionMethod($this, 'writeCacheFile');
      #     if ($r->getDeclaringClass()->getName() !== __CLASS__) {
      #         @trigger_error('The Twig_Environment::writeCacheFile method is deprecated and will be removed in Twig 2.0.', E_USER_DEPRECATED);
      #         @bc_write_cache_file = true;
      #     end
      #     $r = new ReflectionMethod($this, 'get_cache_filename');
      #     if ($r->getDeclaringClass()->getName() !== __CLASS__) {
      #         @trigger_error('The Twig_Environment::get_cache_filename method is deprecated and will be removed in Twig 2.0.', E_USER_DEPRECATED);
      #         @bc_get_cache_filename = true;
      #     end
      # end
    end

    # Enables debugging mode.
    def enable_debug
      @debug = true
    end

    # Disables debugging mode.
    def disable_debug
      @debug = false
    end

    # Checks if debug mode is enabled.
    #
    # @return bool true if debug mode is enabled, false otherwise
    def is_debug
      @debug
    end

    # Enables the auto_reload option.
    def enable_auto_reload
      @auto_reload = true
    end

    # Disables the auto_reload option.
    def disable_auto_reload
      @auto_reload = false
    end

    # Checks if the auto_reload option is enabled.
    #
    # @return bool true if auto_reload is enabled, false otherwise
    def is_auto_reload
      @auto_reload
    end

    # Enables the strict_variables option.
    def enable_strict_variables
      @strict_variables = true
    end

    # Disables the strict_variables option.
    def disable_strict_variables
      @strict_variables = false
    end

    # Checks if the strict_variables option is enabled.
    #
    # @return bool true if strict_variables is enabled, false otherwise
    def is_strict_variables
      @strict_variables
    end

    # Gets the current cache implementation.
    #
    # @param bool $original Whether to return the original cache option or the real cache instance
    #
    # @return Twig_CacheInterface|string|false A Twig_CacheInterface implementation,
    #                                          an absolute path to the compiled templates,
    #                                          or false to disable cache
    def get_cache(original = true)
      original ? @original_cache : @cache
    end

    # Sets the current cache implementation.
    #
    # @param Twig::Cache|string|false cache A Twig::Cache implementation,
    #                                                an absolute path to the compiled templates,
    #                                                or false to disable cache
    def set_cache(cache)
      if cache.is_a?(String)
        @original_cache = cache
        @cache = Twig::Cache::Filesystem.new(cache)
      elsif (false == cache)
        @original_cache = cache;
        @cache = Twig::Cache::Null.new
      else
        @original_cache = @cache = cache
      end
    end

    # # Gets the cache filename for a given template.
    # #
    # # @param string name The template name
    # #
    # # @return string|false The cache file name or false when caching is disabled
    # #
    # # @deprecated since 1.22 (to be removed in 2.0)
    # def get_cache_filename(name)
    #     @trigger_error(sprintf('The %s method is deprecated and will be removed in Twig 2.0.', __METHOD__), E_USER_DEPRECATED);
    #     key = @cache->generateKey(name, $this->get_template_class(name));
    #     return !key ? false : key;
    # end

    # Gets the template class associated with the given string.
    #
    # The generated template class is based on the following parameters:
    #
    #  # The cache key for the given template;
    #  # The currently enabled extensions;
    #  # Whether the Twig C extension is available or not.
    #
    # @param string   name  The name for which to calculate the template class name
    # @param int|nil index The index if it is an embedded template
    #
    # @return string The template class name
    def get_template_class(name, index = nil)
      name ||= ''
      # key = loader.get_cache_key(name)
      # key = key + @extensions.keys.to_s
      # key = + function_exists('twig_template_get_attributes')
      # @template_class_prefix.hash('sha256', key) + (index.nil? ? '' : '_' + index)
      "Twig::Template_#{Digest::MD5.new.update(name).hexdigest}"
    end

    # Renders a template.
    #
    # @param name [String]  The template name
    # @param context [Hash] An hash of parameters to pass to the template
    #
    # @return [String] The rendered template
    #
    # @raise Twig::Error::Loader  When the template cannot be found
    # @raise Twig::Error::Syntax  When an error occurred during compilation
    # @raise Twig::Error::Runtime When an error occurred during rendering
    def render(template_name, context = {})
      load_template(template_name).render(context)
    end

    # Displays a template.
    #
    # @param string name    The template name
    # @param array  $context An array of parameters to pass to the template
    #
    # @raise Twig::Error::Loader  When the template cannot be found
    # @raise Twig::Error::Syntax  When an error occurred during compilation
    # @raise Twig::Error::Runtime When an error occurred during rendering
    def display(template_name, context = {})
      load_template(template_name).display(context)
    end

    # Loads a template by name.
    #
    # @param string name  The template name
    # @param int    index The index if it is an embedded template
    #
    # @return Twig::Template A template instance representing the given template name
    #
    # @raise Twig::Error::Loader When the template cannot be found
    # @raise Twig::Error::Syntax When an error occurred during compilation
    def load_template(name, index = nil)
      klass_name = get_template_class(name, index)
      if @loaded_templates.key?(klass_name)
        return @loaded_templates[klass_name]
      end
      # unless defined? klass_name
      #   if (@bc_get_cache_filename)
      #     key = get_cache_filename(name)
      #   else
      #     key = @cache.generate_key(name, klass_name)
      #   end
      #   if (!is_auto_reload() || is_template_fresh(name, @cache.get_timestamp(key)))
      #     @cache.load(key)
      #   end
      #   if (!class_exists(klass_name, false))
          content = compile_source(loader.get_source(name), name)
      #     if (@bc_write_cache_file)
      #       write_cache_file(key, content)
      #     else
      #       @cache.write(key, content)
      #     end

          if is_debug
          puts content
          end
          eval(content)
      #   end
      # end
      init_runtime if !@runtime_initialized
      klass = klass_name.split('::').inject(Object) {|o,c| o.const_get c}
      @loaded_templates[klass_name] = klass.new(self)
    end

    # # Creates a template from source.
    # #
    # # This method should not be used as a generic way to load templates.
    # #
    # # @param string $template The template name
    # #
    # # @return Twig_Template A template instance representing the given template name
    # #
    # # @raise Twig::Error::Loader When the template cannot be found
    # # @raise Twig::Error::Syntax When an error occurred during compilation
    # def create_template(template, name)
    #   loader = Twig::Loader::Chain.new([
    #     Twig::Loader::Array.new({ name => template }),
    #     current = loader
    #   ))
    #   set_loader(loader)
    #   begin
    #     template = load_template(name)
    #   raise => ex
    #     set_loader(current)
    #     raise
    #   end
    #   set_loader(current)
    #   template
    # end

    # Returns true if the template is still fresh.
    #
    # Besides checking the loader for freshness information,
    # this method also checks if the enabled extensions have
    # not changed.
    #
    # @param string name The template name
    # @param int    $time The last modification time of the cached template
    #
    # @return bool true if the template is fresh, false otherwise
    def is_template_fresh(name, time)
      raise 'check this'
      # if (0 == @last_modified_extension)
      #   @extensions.each do |extension|
      #     r = ReflectionObject.new(extension)
      #     if (file_exists(r.filename) && (extensionTime = filemtime(r.filename)) > @last_modified_extension)
      #         @last_modified_extension = extensionTime
      #     end
      #   end
      # end
      # @last_modified_extension <= time && loader.is_fresh(name, time)
    end

    # Tries to load a template consecutively from an array.
    #
    # Similar to loadTemplate() but it also accepts Twig::Template instances and an array
    # of templates where each is tried to be loaded.
    #
    # @param string|Twig_Template|array names A template or an array of templates to try consecutively
    #
    # @return Twig::Template
    #
    # @raise Twig::Error::Loader When none of the templates can be found
    # @raise Twig::Error::Syntax When an error occurred during compilation
    def resolve_template(names)
      unless names.is_a?(::Array)
        names = [names]
      end
      names.each do |name|
        next if name.nil?
        return name if name.is_a?(Twig::Template)
        begin
          return load_template(name)
        rescue Twig::Error::Loader
        end
      end
      if names.length == 1
        raise
      end
      raise Twig::Error::Loader.new("Unable to find one of the following templates: \"#{names.join(',')}\".")
    end

    # Clears the internal template cache.
    #
    def clear_template_cache()
      @loaded_templates = []
    end

    # # Clears the template cache files on the filesystem.
    # #
    # # @deprecated since 1.22 (to be removed in 2.0)
    # def clearCacheFiles()
    #     @trigger_error(sprintf('The %s method is deprecated and will be removed in Twig 2.0.', __METHOD__), E_USER_DEPRECATED);
    #     if (is_string(@original_cache)) {
    #         foreach (new RecursiveIteratorIterator(new RecursiveDirectoryIterator(@original_cache), RecursiveIteratorIterator::LEAVES_ONLY) as $file) {
    #             if ($file->isFile()) {
    #                 @unlink($file->getPathname());
    #             end
    #         end
    #     end
    # end

    # Gets the Lexer instance.
    #
    # @return Twig::Lexer A Twig::Lexer instance
    def lexer
      @lexer ||= Twig::Lexer.new(self)
    end

    # Sets the Lexer instance.
    #
    # @param lexer [Twig::Lexer] A Twig::Lexer instance
    def lexer=(lexer)
      @lexer = lexer
    end

    # Tokenizes a source code.
    #
    # @param source [String] The template source code
    # @param name [String] The template name
    #
    # @return Twig_TokenStream A Twig_TokenStream instance
    #
    # @raise Twig::Error::Syntax When the code is syntactically wrong
    def tokenize(source, name = nil)
      lexer.tokenize(source, name)
    end

    # Gets the Parser instance.
    #
    # @return [Twig::Parser] A Twig::Parser instance
    def parser
      @parser ||= Parser.new(self)
    end

    # Sets the Parser instance.
    #
    # @param parser [Twig::Parser] A Twig::Parser instance
    def parser=(parser)
      @parser = parser
    end

    # Converts a token stream to a node tree.
    #
    # @param stream [Twig::TokenStream] A token stream instance
    #
    # @return [Twig::Node::Module] A node tree
    #
    # @raise [Twig::Error::Syntax] When the token stream is syntactically or semantically wrong
    def parse(stream)
      parser.parse(stream)
    end

    def parse_source(source, name = nil)
      parse(tokenize(source, name))
    end

    # Gets the Compiler instance.
    #
    # @return Twig::CompilerInterface A Twig::CompilerInterface instance
    def get_compiler
      @compiler ||= Twig::Compiler.new(self)
    end

    # Sets the Compiler instance.
    #
    # @param Twig::CompilerInterface compiler A Twig::CompilerInterface instance
    def set_compiler(compiler)
      @compiler = compiler
    end

    # Compiles a node and returns the code.
    #
    # @param Twig_NodeInterface $node A Twig_NodeInterface instance
    #
    # @return string The compiled PHP source code
    def compile(node)
      get_compiler.compile(node).get_source
    end

    # Compiles a template source code.
    #
    # @param string $source The template source code
    # @param string name   The template name
    #
    # @return string The compiled PHP source code
    #
    # @raise Twig::Error::Syntax When there was an error during tokenizing, parsing or compiling
    def compile_source(source, name = nil)
      begin
        compiled = compile(parse_source(source, name))
        # if (isset(source[0]))
        #   compiled +=  '/* ' + str_replace(array('*/', "\r\n", "\r", "\n"), array('*//* ', "\n", "\n", "*/\n/* "), $source)."*/\n"
        # end
        compiled
      rescue Twig::Error => ex
        ex.set_template_file(name)
        raise
      rescue => ex
        raise Twig::Error::Syntax.new("An exception has been thrown during the compilation of a template (\"#{ex.message}\").")
      end
    end

    # Sets the Loader instance.
    #
    # @param Twig::Loader loader A Twig_LoaderInterface instance
    def loader=(loader)
      @loader = loader
    end

    # Gets the Loader instance.
    #
    # @return Twig::Loader A Twig::Loader instance
    def loader
      if @loader.nil?
        raise Twig::LogicException.new('You must set a loader first.')
      end
      @loader
    end

    # Sets the default template charset.
    #
    # @param string charset The default charset
    def set_charset(charset)
      @charset = charset.upcase
    end

    # Gets the default template charset.
    #
    # @return string The default charset
    def get_charset
      @charset
    end

    # Initializes the runtime environment.
    #
    # @deprecated since 1.23 (to be removed in 2.0)
    def init_runtime
      @runtime_initialized = true
      get_extensions.each do |name, extension|
        # if !extension.is_a?(Twig::Extension::InitRuntimeInterface)
        #   m = ReflectionMethod.new(extension, 'init_runtime')
        #   if ('Twig_Extension' != m.get_declaring_class.get_name)
        #     # @trigger_error(sprintf('Defining the init_runtime() method in the "%s" extension is deprecated. Use the `needs_environment` option to get the Twig_Environment instance in filters, functions, or tests; or explicitly implement Twig_Extension_InitRuntimeInterface if needed (not recommended).', name), E_USER_DEPRECATED);
        #   end
        # end
        extension.init_runtime(self)
      end
    end

    # Returns true if the given extension is registered.
    #
    # @param string name The extension name
    #
    # @return bool Whether the extension is registered or not
    def has_extension(name)
      @extensions.key?(name)
    end

    # Gets an extension by name.
    #
    # @param string name The extension name
    #
    # @return Twig::Extension A Twig::Extension instance
    def get_extension(name)
      if !@extensions.key?(name)
        raise Twig::Error::Runtime.new("The \"#{name}\" extension is not enabled.")
      end
      @extensions[name]
    end

    # Registers an extension.
    #
    # @param extension A [Twig::Extension] instance
    def add_extension(extension)
      name = extension.get_name
      if (@extension_initialized)
        raise Twig::LogicException.new("Unable to register extension '#{name}' as extensions have already been initialized.")
      end
      if @extensions.key?(name)
        raise Twig::LogicException.new("Extension '#{name}' ready registered.")
      end
      @last_modified_extension = 0
      @extensions[name] = extension
    end

    # # Removes an extension by name.
    # #
    # # This method is deprecated and you should not use it.
    # #
    # # @param string name The extension name
    # #
    # # @deprecated since 1.12 (to be removed in 2.0)
    # def removeExtension(name)
    #     @trigger_error(sprintf('The %s method is deprecated and will be removed in Twig 2.0.', __METHOD__), E_USER_DEPRECATED);
    #     if (@extension_initialized)
    #         raise Twig::LogicException.new(sprintf('Unable to remove extension "%s" as extensions have already been initialized.', name));
    #     end
    #     unset(@extensions[name]);
    # end

    # Registers an array of extensions.
    #
    # @param array extensions An array of extensions
    def set_extensions(extensions)
      extensions.each do |extension|
        add_extension(extension)
      end
      true
    end

    # Returns all registered extensions.
    #
    # @return array An array of extensions
    def get_extensions
      @extensions
    end

    # Registers a Token Parser.
    #
    # @param parser [Twig::TokenParser] A Twig:TokenParser instance
    def add_token_parser(parser)
      if (@extension_initialized)
        raise Twig::LogicException.new('Unable to add a token parser as extensions have already been initialized.');
      end
      @staging.add_token_parser(parser)
    end

    # Gets the registered Token Parsers.
    #
    # @return [Twig::TokenParserBroker] A broker containing token parsers
    def get_token_parsers
      init_extensions if !@extension_initialized
      @parsers
    end

    # Gets registered tags.
    #
    # Be warned that this method cannot return tags defined by Twig_TokenParserBrokerInterface classes.
    #
    # @return Twig::TokenParser[] An array of Twig::TokenParser instances
    def get_tags
      tags = {}
      get_token_parsers.get_parsers.each do |tag, parser|
        tags[tag] = parser
      end
      tags
    end

    # Registers a Node Visitor.
    #
    # @param Twig::NodeVisitor visitor A Twig::NodeVisitor instance
    def add_node_visitor(visitor)
      if @extension_initialized
        raise Twig::LogicException.new('Unable to add a node visitor as extensions have already been initialized.');
      end
      @staging.add_node_visitor(visitor)
    end

    # Gets the registered Node Visitors.
    #
    # @return Twig_NodeVisitorInterface[] An array of Twig_NodeVisitorInterface instances
    def get_node_visitors
      init_extensions unless @extension_initialized
      @visitors
    end

    # Registers a Filter.
    #
    # @param filter [Twig::SimpleFilter] A Twig::SimpleFilter instance
    def add_filter(filter)
      name = filter.name
      if @extension_initialized
        raise Twig::LogicException.new("Unable to add filter \"#{name}\" as extensions have already been initialized.")
      end
      @staging.add_filter(name, filter)
    end

    # Get a filter by name.
    #
    # Subclasses may override this method and load filters differently;
    # so no list of filters is available.
    #
    # @param string name The filter name
    #
    # @return Twig::Filter|false A Twig::Filter instance or false if the filter does not exist
    def get_filter(name)
      init_extensions unless @extension_initialized

      if @filters.key?(name)
        return @filters[name]
      end

      # @filters.each do |pattern, filter|
      #   pattern = str_replace('\\*', '(.*?)', preg_quote(pattern, '#'), $count);
      #   if ($count) {
      #     if (preg_match('#^'.pattern.'$#', name, matches)) {
      #         array_shift(matches);
      #         filter.setArguments(matches);
      #         return filter;
      #     end
      #   end
      # end
      @filter_callbacks.each do |callback|
        if (filter = call_user_func(callback, name))
          return filter
        end
      end
      nil
    end

    # def registerUndefinedFilterCallback(callable)
    #   @filter_callbacks << callable
    # end

    # Gets the registered Filters.
    #
    # Be warned that this method cannot return filters defined with registerUndefinedFilterCallback.
    #
    # @return Twig_FilterInterface[] An array of Twig_FilterInterface instances
    #
    # @see registerUndefinedFilterCallback
    def get_filters
      init_extensions unless @extension_initialized
      @filters
    end

    # Registers a Test.
    #
    # @param string|Twig::SimpleTest             name The test name or a Twig_SimpleTest instance
    # @param Twig::Test|Twig::SimpleTest test A Twig_TestInterface instance or a Twig_SimpleTest instance
    def add_test(test)
      unless test.is_a?(Twig::SimpleTest)
        raise Twig::LogicException.new('A test must be an instance of Twig::SimpleTest')
      end
      if @extension_initialized
        raise Twig::LogicException.new("Unable to add test \"#{name}\" as extensions have already been initialized.")
      end
      @staging.add_test(test.get_name, test)
    end

    # Gets the registered Tests.
    #
    # @return Twig_TestInterface[] An array of Twig_TestInterface instances
    def get_tests
      init_extensions if !@extension_initialized
      @tests
    end

    # Gets a test by name.
    #
    # @param string name The test name
    #
    # @return Twig::Test|nil A Twig::Test instance or nil if the test does not exist
    def get_test(name)
      init_extensions if !@extension_initialized
      @tests[name]
    end

    # Registers a Function.
    #
    # @param function [Twig::SimpleFunction] A Twig::SimpleFunction instance
    def add_function(function)
      unless function.is_a?(Twig::SimpleFunction)
        raise Twig::LogicException.new('A function must be an instance of Twig::SimpleFunction')
      end
      if @extension_initialized
        raise Twig::LogicException.new("Unable to add function \"#{function.name}\" as extensions have already been initialized.")
      end
      @staging.add_function(function.name, function)
    end

    # Get a function by name.
    #
    # Subclasses may override this method and load functions differently;
    # so no list of functions is available.
    #
    # @param string name function name
    #
    # @return Twig_Function|false A Twig_Function instance or false if the function does not exist
    def get_function(name)
      init_extensions unless @extension_initialized

      if @functions.key?(name)
        return @functions[name]
      end

      @functions.each do |pattern, function|
      #   pattern = str_replace('\\*', '(.*?)', preg_quote(pattern, '#'), $count)
      #   if ($count)
          if name =~ /\A#{pattern}\z/
            # array_shift(matches);
            function.set_arguments(matches)
            return function
          end
      #   end
      end

      @function_callbacks.each do |callback|
        if (function = call_user_func(callback, name))
          return function
        end
      end
      false
    end

    def register_undefined_function_callback(callable)
      @function_callbacks << callable
    end

    # Gets registered functions.
    #
    # Be warned that this method cannot return functions defined with registerUndefinedFunctionCallback.
    #
    # @return Twig_FunctionInterface[] An array of Twig_FunctionInterface instances
    #
    # @see registerUndefinedFunctionCallback
    def get_functions
      init_extensions if !@extension_initialized
      @functions
    end

    # Registers a Global.
    #
    # New globals can be added before compiling or rendering a template;
    # but after, you can only update existing globals.
    #
    # @param string name  The global name
    # @param mixed  value The global value
    def add_global(name, value)
      if @extension_initialized || @runtime_initialized
        @globals ||= init_globals

        unless @globals.key?(name)
          raise Twig::LogicException.new("Unable to add global \"#{name}\" as the runtime or the extensions have already been initialized.")
        end
      end
      if @extension_initialized || @runtime_initialized
        # update the value
        @globals[name] = value
      else
        @staging.add_global(name, value)
      end
    end

    # Gets the registered Globals.
    #
    # @return array An array of globals
    def get_globals
      init_extensions if !@extension_initialized

      @globals ||= init_globals
    end

    # Merges a context with the defined globals.
    #
    # @param array $context An array representing the context
    #
    # @return array The context merged with the globals
    def merge_globals(context)
      # we don't use array_merge as the context being generally
      # bigger than globals, this code is faster.
      get_globals.each do |key, value|
        if !context.key?(key)
          context[key] = value
        end
      end
      context
    end

    # Gets the registered unary Operators.
    #
    # @return array An array of unary operators
    def get_unary_operators
      init_extensions unless @extension_initialized

      @unary_operators
    end

    # Gets the registered binary Operators.
    #
    # @return array An array of binary operators
    def get_binary_operators
      init_extensions unless @extension_initialized

      @binary_operators
    end

    # # @deprecated since 1.23 (to be removed in 2.0)
    # def computeAlternatives(name, $items)
    #     @trigger_error(sprintf('The %s method is deprecated and will be removed in Twig 2.0.', __METHOD__), E_USER_DEPRECATED);
    #     return Twig::Error::Syntax.compute_alternatives(name, $items);
    # end

    def init_globals
      globals = {}
      @extensions.each do |name, extension|
        # if !extension.is_a?(Twig::Extension::GlobalsInterface)
        #   m = ReflectionMethod.new(extension, 'getGlobals')
        #   if ('Twig_Extension' != m.get_declaring_class.get_name)
        #     # @trigger_error(sprintf('Defining the getGlobals() method in the "%s" extension is deprecated without explicitly implementing Twig_Extension_GlobalsInterface.', name), E_USER_DEPRECATED);
        #   end
        # end
        ext_glob = extension.get_globals
        unless ext_glob.is_a?(::Hash)
          # raise UnexpectedValueException.(sprintf('"%s::getGlobals()" must return an array of globals.', extension.class.name));
        end
        globals.merge!(ext_glob)
      end
      globals.merge!(@staging.get_globals)
    end

    def init_extensions
      return if @extension_initialized

      @extension_initialized = true
      @parsers = Twig::TokenParserBroker.new([], [], false)
      @filters = {}
      @functions = {}
      @tests = {}
      @visitors = []
      @unary_operators = {}
      @binary_operators= {}
      @extensions.each do |name, extension|
        init_extension(extension)
      end
      init_extension(@staging)
    end

    def init_extension(extension)
      # filters
      extension.get_filters.each do |filter|
        @filters[filter.get_name] = filter
      end

      # functions
      extension.get_functions.each do |function|
        @functions[function.name] = function
      end

      # tests
      extension.get_tests.each do |test|
        @tests[test.get_name] = test
      end

      # token parsers
      extension.get_token_parsers.each do |parser|
        @parsers.add_token_parser(parser)
        @parsers.add_token_parser(parser)
      end

      # node visitors
      extension.get_node_visitors.each do |visitor|
        @visitors << visitor
      end

      # operators
      if (operators = extension.get_operators)
        if operators.length != 2
          raise InvalidArgumentException #.new(sprintf('"%s::getOperators()" does not return a valid operators array.', extension.class.name));
        end
        @unary_operators = @unary_operators.merge operators[0]
        @binary_operators = @binary_operators.merge operators[1]
      end
    end

    # # @deprecated since 1.22 (to be removed in 2.0)
    # protected function writeCacheFile($file, $content)
    #     @cache.write($file, $content);
    # end
  end
end
