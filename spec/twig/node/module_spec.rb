describe Twig::Node::Module do
  it 'Constructor' do
    body = Twig::Node::Text.new('foo', 1)

    parent = Twig::Node::Expression::Constant.new('layout.twig', 1)

    blocks = Twig::Node.new
    macros = Twig::Node.new
    traits = Twig::Node.new
    filename = 'foo.twig'

    node = Twig::Node::Module.new(body, parent, blocks, macros, traits, Twig::Node.new, filename)

    expect(node.get_node(:body)).to eq(body)
    expect(node.get_node(:blocks)).to eq(blocks)
    expect(node.get_node(:macros)).to eq(macros)
    expect(node.get_node('parent')).to eq(parent)
    expect(node.get_attribute('filename')).to eq(filename)
  end

  describe ' ' do
    let(:environment) {
      Twig::Environment.new(nil)
    }
    let(:compiler) {
      Twig::Compiler.new(environment)
    }

    it ' ' do
      # twig = Twig::Environment.new(double('Twig_LoaderInterface'))

      body = Twig::Node::Text.new('foo', 1)

      extends = nil

      blocks = Twig::Node.new
      macros = Twig::Node.new
      traits = Twig::Node.new
      filename = 'foo.twig'

      node = Twig::Node::Module.new(body, extends, blocks, macros, traits, Twig::Node.new, filename)

      expect(compiler.compile(node).get_source).to eq(<<-EOF
class Twig::Template_be925a7b06dda0dfdbd18a1509f7eb34 < Twig::Template
  def initialize(env)
    super(env)
    @parent = nil
    @blocks = {
    }
  end

  def do_display(_context, blocks = {})
    _twigout = []
    # line 1
    _twigout << "foo"
    _twigout.join
  end

  def get_template_name
    "foo.twig"
  end

  def get_debug_info
    {1=>1}
  end
end
EOF
      )
    end

    it ' ' do
      import = Twig::Node::Import.new(Twig::Node::Expression::Constant.new('foo.twig', 1), Twig::Node::Expression::AssignName.new('macro', 1), 2)

      body = Twig::Node.new([import])
      extends = Twig::Node::Expression::Constant.new('layout.twig', 1)
      blocks = Twig::Node.new
      macros = Twig::Node.new
      traits = Twig::Node.new
      filename = 'foo.twig'

      node = Twig::Node::Module.new(body, extends, blocks, macros, traits, Twig::Node.new, filename)

      expect(compiler.compile(node).get_source).to eq(<<-EOF
class Twig::Template_be925a7b06dda0dfdbd18a1509f7eb34 < Twig::Template
  def initialize(env)
    super(env)
    # line 1
    @parent = load_template("layout.twig", "foo.twig", 1)
    @blocks = {
    }
  end

  def do_get_parent(_context)
    "layout.twig"
  end

  def do_display(_context, blocks = {})
    _twigout = []
    # line 2
    _context["macro"] = load_template("foo.twig", "foo.twig", 2)
    # line 1
    _twigout << @parent.display(_context, @blocks.merge(blocks))
    _twigout.join
  end

  def get_template_name
    "foo.twig"
  end

  def is_traitable
    false
  end

  def get_debug_info
    {1=>1, 5=>2, 21=>1}
  end
end
EOF
      )
    end

    it ' ' do
      set = Twig::Node::Set.new(false, Twig::Node.new([Twig::Node::Expression::AssignName.new('foo', 4)]), Twig::Node.new([Twig::Node::Expression::Constant.new('foo', 4)]), 4)

      body = Twig::Node.new([set])

      extends = Twig::Node::Expression::Conditional.new(
        Twig::Node::Expression::Constant.new(true, 2),
        Twig::Node::Expression::Constant.new('foo', 2),
        Twig::Node::Expression::Constant.new('foo', 2),
        2
      )
      blocks = Twig::Node.new
      macros = Twig::Node.new
      traits = Twig::Node.new
      filename = 'foo.twig'

      node = Twig::Node::Module.new(body, extends, blocks, macros, traits, Twig::Node.new, filename)

      expect(compiler.compile(node).get_source).to eq(<<-EOF
class Twig::Template_be925a7b06dda0dfdbd18a1509f7eb34 < Twig::Template
  def initialize(env)
    super(env)
    @blocks = {
    }
  end

  def do_get_parent(_context)
    # line 2
    load_template(((true) ? ("foo") : ("foo")), "foo.twig", 2)
  end

  def do_display(_context, blocks = {})
    _twigout = []
    # line 4
    _context["foo"] = "foo"
    # line 2
    _twigout << get_parent(_context).display(_context, @blocks.merge(blocks))
    _twigout.join
  end

  def get_template_name
    "foo.twig"
  end

  def is_traitable
    false
  end

  def get_debug_info
    {1=>2, 10=>4, 25=>2}
  end
end
EOF
      )
    end
  end
end
