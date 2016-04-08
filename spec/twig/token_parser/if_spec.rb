describe Twig::TokenParser::If do
  let(:twig) {
    Twig::Environment.new(double('Twig::Loader::Array'), {
      'autoescape' => false,
      'optimizations' => 0,
    })
  }

  it ' ' do
    pp twig.parse(twig.tokenize(<<-EOF
{% if true %}
{% elseif true %}
{% else %}
{% endif %}
EOF
    ))
  end

  it ' ' do
    pp twig.parse(twig.tokenize(<<-EOF
{% if a == true %}
{% endif %}
EOF
    ))
  end
end
