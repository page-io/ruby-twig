describe Twig::TokenStream do

  let(:tokens) {
    [
      Twig::Token.new(:text_type, 1, 1),
      Twig::Token.new(:text_type, 2, 1),
      Twig::Token.new(:text_type, 3, 1),
      Twig::Token.new(:text_type, 4, 1),
      Twig::Token.new(:text_type, 5, 1),
      Twig::Token.new(:text_type, 6, 1),
      Twig::Token.new(:text_type, 7, 1)
    ]
  }

  it 'loop until eos' do
    stream = Twig::TokenStream.new(tokens)

    repr = []

    while !stream.eos?
      token = stream.next

      repr << token.value
    end

    expect(repr).to eq([1, 2, 3, 4, 5, 6, 7])
  end

  it 'testEndOfTemplateNext' do
    stream = Twig::TokenStream.new([
      Twig::Token.new(:block_start_type, 1, 1)
    ])

    while !stream.eos?
      stream.next
    end
  end

  it 'testEndOfTemplateLook' do
    stream = Twig::TokenStream.new([
      Twig::Token.new(:block_start_type, 1, 1)
    ])
    expect{
      while !stream.eos?
        stream.look
        stream.next
      end
   }.not_to raise_error # Twig::Error::Syntax
  end
end
