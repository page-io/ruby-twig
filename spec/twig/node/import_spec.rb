describe Twig::Node::Import do

  it 'Constructor' do
    macro = Twig::Node::Expression::Constant.new('foo.twig', 1)
    var = Twig::Node::Expression::AssignName.new('macro', 1)
    node = Twig::Node::Import.new(macro, var, 1)

    expect(node.get_node(:expr)).to eq(macro)
    expect(node.get_node('var')).to eq(var)
  end

  describe ' ' do
    let(:environment) {
      Twig::Environment.new(nil)
    }
    let(:compiler) {
      Twig::Compiler.new(environment)
    }

    it ' ' do
      macro = Twig::Node::Expression::Constant.new('foo.twig', 1)

      var = Twig::Node::Expression::AssignName.new('macro', 1)

      node = Twig::Node::Import.new(macro, var, 1)

      expect(compiler.compile(node).get_source).to eq(<<-EOF
# line 1
_context["macro"] = load_template("foo.twig", nil, 1)
EOF
      )
    end
  end
end
