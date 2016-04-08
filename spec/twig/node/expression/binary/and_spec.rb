describe Twig::Node::Expression::Binary::And do

  it 'Constructor' do
    left = Twig::Node::Expression::Constant.new(1, 1)
    right = Twig::Node::Expression::Constant.new(2, 1)
    node = Twig::Node::Expression::Binary::And.new(left, right, 1)

    expect(node.get_node('left')).to eq(left)
    expect(node.get_node('right')).to eq(right)
  end

  let(:environment) {
    Twig::Environment.new(nil)
  }
  let(:compiler) {
    Twig::Compiler.new(environment)
  }

  it ' ' do
    left = Twig::Node::Expression::Constant.new(1, 1)
    right = Twig::Node::Expression::Constant.new(2, 1)
    node = Twig::Node::Expression::Binary::And.new(left, right, 1)

    expect(compiler.compile(node).get_source).to eq('(1 && 2)')
  end
end
