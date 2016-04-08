describe Twig::Loader::Array do

  it 'get_source' do
    loader = Twig::Loader::Array.new({'foo' => 'bar'})

    expect(loader.get_source('foo')).to eq('bar')
  end

  #
  # @expectedException Twig_Error_Loader
  #
  it 'get_source When Template Does Not Exist' do
    loader = Twig::Loader::Array.new({})

    expect{ loader.get_source('foo')}.to raise_error(Twig::Error::Loader, 'Template "foo" is not defined')
  end

  it 'get_cache_key' do
    loader = Twig::Loader::Array.new({ 'foo' => 'bar' })

    expect(loader.get_cache_key('foo')).to eq('bar')
  end

  #
  # @expectedException Twig_Error_Loader
  #
  it 'get_cache_key When Template Does Not Exist' do
    loader = Twig::Loader::Array.new({})

    expect{loader.get_cache_key('foo')}.to raise_error(Twig::Error::Loader, 'Template "foo" is not defined')
  end

  it 'set_template' do
    loader = Twig::Loader::Array.new({})
    loader.set_template('foo', 'bar')

    expect(loader.get_source('foo')).to eq('bar')
  end

  it 'is_fresh' do
    loader = Twig::Loader::Array.new({ 'foo' => 'bar' })

    expect(loader.is_fresh('foo', Time.now)).to eq(true)
  end

  #
  # @expectedException Twig_Error_Loader
  #
  it 'is_fresh When Template Does Not Exist' do
    loader = Twig::Loader::Array.new({})

    expect{loader.is_fresh('foo', Time.now)}.to raise_error(Twig::Error::Loader, 'Template "foo" is not defined')
  end

  # it 'Template Reference' do
  #   class Twig_Test_Loader_TemplateReference
  #     def initialize(name)
  #       @name = name
  #     end
  #
  #     def to_str
  #       @name
  #     end
  #   end
  #
  #   name = Twig_Test_Loader_TemplateReference.new('foo')
  #
  #   loader = Twig::Loader::Array.new({ 'foo' => 'bar' })
  #
  #   loader.get_cache_key(name)
  #
  #   loader.get_source(name)
  #
  #   loader.is_fresh(name, Time.now)
  #
  #   loader.set_template(name, 'foobar')
  # end
end
