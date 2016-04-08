describe Twig::Loader::Filesystem do

  it 'getSecurityTests' do
    [
      "compiler_spec\0.rb",
      '..\\compiler_spec.rb',
      '..\\\\\\compiler_spec.rb',
      '../compiler_spec.rb',
      '..////compiler_spec.rb',
      './../compiler_spec.rb',
      '.\\..\\compiler_spec.rb',
      '././././././../compiler_spec.rb',
      '.\\./.\\./.\\./../compiler_spec.rb',
      'foo/../../compiler_spec.rb',
      'foo\\..\\..\\compiler_spec.rb',
      'foo/../bar/../../compiler_spec.rb',
      'foo/bar/../../../compiler_spec.rb',
      'filters/../../compiler_spec.rb',
      'filters//..//..//compiler_spec.rb',
      'filters\\..\\..\\compiler_spec.rb',
      'filters\\\\..\\\\..\\\\compiler_spec.rb',
      'filters\\//../\\/\\..\\compiler_spec.rb',
      '/../compiler_spec.rb'
    ].each do |template|

      loader = Twig::Loader::Filesystem.new(File.dirname(__FILE__) + '/../../fixtures')

      expect{loader.get_cache_key(template)}.to raise_error(Twig::Error::Loader)
    end
  end

  # def testPaths()
  #     $basePath = dirname(__FILE__).'/Fixtures';
  #     loader = new Twig_Loader_Filesystem(array($basePath.'/normal', $basePath.'/normal_bis'))

  #     loader->setPaths(array($basePath.'/named', $basePath.'/named_bis'), 'named')

  #     loader->addPath($basePath.'/named_ter', 'named')

  #     loader->addPath($basePath.'/normal_ter')

  #     loader->prependPath($basePath.'/normal_final')

  #     loader->prependPath($basePath.'/named/../named_quater', 'named')

  #     loader->prependPath($basePath.'/named_final', 'named')

  #     expect(array(
  #         $basePath.'/normal_final',
  #         $basePath.'/normal',
  #         $basePath.'/normal_bis',
  #         $basePath.'/normal_ter',
  #     ), loader->getPaths())

  #     expect(array(
  #         $basePath.'/named_final',
  #         $basePath.'/named/../named_quater',
  #         $basePath.'/named',
  #         $basePath.'/named_bis',
  #         $basePath.'/named_ter',
  #     ), loader->getPaths('named'))

  #     expect(
  #         realpath($basePath.'/named_quater/named_absolute.html'),
  #         realpath(loader->getCacheKey('@named/named_absolute.html'))
  #     )

  #     expect("path (final)\n", loader->getSource('index.html'))

  #     expect("path (final)\n", loader->getSource('@__main__/index.html'))

  #     expect("named path (final)\n", loader->getSource('@named/index.html'))
  # end

  # def testEmptyConstructor()
  #     loader = new Twig_Loader_Filesystem()

  #     expect([], loader->getPaths())
  # end

  # def testGetNamespaces()
  #     loader = new Twig_Loader_Filesystem(sys_get_temp_dir())

  #     expect(array(Twig_Loader_Filesystem::MAIN_NAMESPACE), loader->getNamespaces())

  #     loader->addPath(sys_get_temp_dir(), 'named')

  #     expect(array(Twig_Loader_Filesystem::MAIN_NAMESPACE, 'named'), loader->getNamespaces())
  # end

  # def testFindTemplateExceptionNamespace()
  #     $basePath = dirname(__FILE__).'/fixtures';
  #     loader = new Twig_Loader_Filesystem(array($basePath.'/normal'))

  #     loader->addPath($basePath.'/named', 'named')

  #     try {
  #         loader->getSource('@named/nowhere.html')

  #     end catch (Exception $e) {
  #         $this->assertInstanceof('Twig_Error_Loader', $e)

  #         $this->assertContains('Unable to find template "@named/nowhere.html"', $e->getMessage())

  #     end
  # end

  # def testFindTemplateWithCache()
  #     $basePath = dirname(__FILE__).'/Fixtures';
  #     loader = new Twig_Loader_Filesystem(array($basePath.'/normal'))

  #     loader->addPath($basePath.'/named', 'named')

  #     // prime the cache for index.html in the named namespace
  #     $namedSource = loader->getSource('@named/index.html')

  #     expect("named path\n", $namedSource)

  #     // get index.html from the main namespace
  #     expect("path\n", loader->getSource('index.html'))
  # end

  # def testLoadTemplateAndRenderBlockWithCache()
  #     loader = new Twig_Loader_Filesystem([])

  #     loader->addPath(dirname(__FILE__).'/Fixtures/themes/theme2')

  #     loader->addPath(dirname(__FILE__).'/Fixtures/themes/theme1')

  #     loader->addPath(dirname(__FILE__).'/Fixtures/themes/theme1', 'default_theme')

  #     twig = Twig::Environment.new(loader)

  #     template = twig.loadTemplate('blocks.html.twig')

  #     $this->assertSame('block from theme 1', template->renderBlock('b1', []))

  #     template = twig.loadTemplate('blocks.html.twig')

  #     $this->assertSame('block from theme 2', template->renderBlock('b2', []))
  # end

  describe 'array inheritance' do
    let(:environment) {
      loader = Twig::Loader::Filesystem.new([])
      loader.add_path(File.dirname(__FILE__) + '/../../fixtures/inheritance')
      Twig::Environment.new(loader)
    }

    it 'valid parent' do
      template = environment.load_template('array_inheritance_valid_parent.html.twig')

      expect(template.render_block(:body, [])).to eq('VALID Child')
    end

    it 'null parent' do
      template = environment.load_template('array_inheritance_null_parent.html.twig')

      expect(template.render_block(:body, [])).to eq('VALID Child')
    end

    it 'empty parent' do
      template = environment.load_template('array_inheritance_empty_parent.html.twig')

      expect(template.render_block(:body, [])).to eq('VALID Child')
    end

    it 'nonexistent parent' do
      template = environment.load_template('array_inheritance_nonexistent_parent.html.twig')

      expect(template.render_block(:body, [])).to eq('VALID Child')
    end
  end

end
