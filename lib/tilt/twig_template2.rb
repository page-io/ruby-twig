module Tilt
  class TwigTemplate2 < Template

    def prepare
      loader = Twig::Loader::Array.new({ file => data })

      if options['paths']
        loader = Twig::Loader::Chain.new([
          loader,
          Twig::Loader::Filesystem.new(options['paths'])
        ])
      end
      @engine = Twig::Environment.new(loader)
    end

    def evaluate(scope, locals, &block)
      locals = locals.inject({}){ |h,(k,v)| h[k.to_s] = v ; h }

      locals['yield'] = block.nil? ? '' : yield
      locals['content'] = locals['yield']

      @engine.render(file,locals)
    end

  end
end
