describe Twig::TokenParser::For do
  it ' ' do
    twig = Twig::Environment.new(double('Twig::Loader::Array'), {
      'autoescape' => false,
      'optimizations' => 0,
    })

    pp twig.parse(twig.tokenize(<<-EOF
{% for a in [] %}
{% endfor %}
EOF
    ))
  end

  it ' ' do
    twig = Twig::Environment.new(double('Twig::Loader::Array'), {
      'autoescape' => false,
      'optimizations' => 0,
    })

    twig.parse(twig.tokenize(<<-EOF
{% for a,b in [] if true %}
{% else %}
{% endfor %}
EOF
    ))
  end

  it 'raise error when using loop variable in if condition' do
    twig = Twig::Environment.new(double())

    expect{twig.parse(twig.tokenize(<<-EOF
{% for a in [] if loop.length %}
{% endfor %}
EOF
    ))}.to raise_error(Twig::Error::Syntax, "At line 1\nThe \"loop\" variable cannot be used in a looping condition.")
  end

  it 'raise error when using loop variable in body with if condition' do
    twig = Twig::Environment.new(double())

    expect{twig.parse(twig.tokenize(<<-EOF
{% for a in [] if true %}
{{ loop.length }}
{% endfor %}
EOF
    ))}.to raise_error(Twig::Error::Syntax, "At line 2\nThe \"loop.length\" variable is not defined when looping with a condition.")
  end

  it '' do
    twig = Twig::Environment.new(double())

    pp twig.parse(twig.tokenize(<<-EOF
{% for a in [1,2,3,4,5,6,7]|batch(3) %}
{% for b in a %}
{{ b }}
{% endfor %}
{% endfor %}
EOF
    ))
  end

end
