module Tilt
  class TwigTemplate < Template
    @@default_output_variable = '_twigout'

    def self.default_output_variable
      @@default_output_variable
    end

    def self.default_output_variable=(name)
      warn "#{self}.default_output_variable= has been replaced with the :outvar-option"
      @@default_output_variable = name
    end

    def prepare
      #TODO! Add a Tilt loader
      @outvar = options[:outvar] || self.class.default_output_variable

      @engine = Twig::Environment.new(Twig::Loader::Array.new)
    end

    def precompiled_template(locals)
      _tokens = @engine.tokenize(data, file)
      _ast = @engine.parse(_tokens)
      _ast = _ast.get_node(:body) if _ast.is_a?(Twig::Node::Module)
      @engine.compile(_ast).tap{|code| puts "#BEGIN CODE\n#{code}\n#END CODE\n" }
    end

    def render(scope=nil, locals={}, &block)
      scope ||= Twig::Runtime.new
      super(scope, locals, &block)
    end

    # def evaluate(scope, locals, &block)
    #   locals = locals.inject({}){ |h,(k,v)| h[k.to_s] = v ; h }
    #   if scope.respond_to?(:to_h)
    #     scope  = scope.to_h.inject({}){ |h,(k,v)| h[k.to_s] = v ; h }
    #     locals = scope.merge(locals)
    #   end
    #   locals['yield'] = block.nil? ? '' : yield
    #   locals['content'] = locals['yield']
    #   @engine.render(locals)
    # end

    def precompiled_preamble(locals)
      output = <<-RUBY
  begin
    #__original_outvar = #{@outvar} if defined?(#{@outvar})
    #{super}
    _context = {}
    _twigout = ''
RUBY
output.tap{ |code| puts "#BEGIN CODE\n#{code}\n#END CODE\n" }
    end

    def precompiled_postamble(locals)
      output = <<-RUBY
        _twigout
        #{super}
      ensure
       #  #{@outvar} = __original_outvar
      end
RUBY
      output.tap{ |code| puts "#BEGIN CODE\n#{code}\n#END CODE\n" }
    end
  end
end
