describe Twig::TokenParser::AutoEscape do
  let(:twig) {
    Twig::Environment.new(double('Twig::Loader::Array'), {
      'autoescape' => false,
      'optimizations' => 0,
    })
  }

  it ' ' do
    pp twig.parse(twig.tokenize(<<-EOF
{% autoescape %}
    Everything will be automatically escaped in this block
    using the HTML strategy
{% endautoescape %}
EOF
    ))
  end

  it ' ' do
    pp twig.parse(twig.tokenize(<<-EOF
{% autoescape 'html' %}
  <p>Everything will be automatically escaped in this block</p>
  <p>using the HTML strategy</p>
{% endautoescape %}
EOF
    ))
  end

  it ' ' do
    pp twig.parse(twig.tokenize(<<-EOF
{% autoescape 'js' %}
    Everything will be automatically escaped in this block
    using the js escaping strategy
{% endautoescape %}
EOF
    ))
  end

  it ' ' do
    pp twig.parse(twig.tokenize(<<-EOF
{% autoescape false %}
    Everything will be outputted as is in this block
{% endautoescape %}
EOF
    ))
  end

end
