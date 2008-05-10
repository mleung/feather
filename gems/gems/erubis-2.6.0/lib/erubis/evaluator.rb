##
## $Rev: 94 $
## $Release: 2.6.0 $
## copyright(c) 2006-2008 kuwata-lab.com all rights reserved.
##

require 'erubis/error'
require 'erubis/context'


module Erubis

  EMPTY_BINDING = binding()


  ##
  ## evaluate code
  ##
  module Evaluator

    def self.supported_properties    # :nodoc:
      return []
    end

    attr_accessor :src, :filename

    def init_evaluator(properties)
      @filename = properties[:filename]
    end

    def result(*args)
      raise NotSupportedError.new("evaluation of code except Ruby is not supported.")
    end

    def evaluate(*args)
      raise NotSupportedError.new("evaluation of code except Ruby is not supported.")
    end

  end


  ##
  ## evaluator for Ruby
  ##
  module RubyEvaluator
    include Evaluator

    def self.supported_properties    # :nodoc:
      list = Evaluator.supported_properties
      return list
    end

    ## eval(@src) with binding object
    def result(_binding_or_hash=TOPLEVEL_BINDING)
      _arg = _binding_or_hash
      if _arg.is_a?(Hash)
        ## load _context data as local variables by eval
        #eval _arg.keys.inject("") { |s, k| s << "#{k.to_s} = _arg[#{k.inspect}];" }
        eval _arg.collect{|k,v| "#{k} = _arg[#{k.inspect}]; "}.join
        _arg = binding()
      end
      return eval(@src, _arg, (@filename || '(erubis)'))
    end

    ## invoke context.instance_eval(@src)
    def evaluate(context=Context.new)
      context = Context.new(context) if context.is_a?(Hash)
      #return context.instance_eval(@src, @filename || '(erubis)')
      @_proc ||= eval("proc { #{@src} }", Erubis::EMPTY_BINDING, @filename || '(erubis)')
      return context.instance_eval(&@_proc)
    end

    ## if object is an Class or Module then define instance method to it,
    ## else define singleton method to it.
    def def_method(object, method_name, filename=nil)
      m = object.is_a?(Module) ? :module_eval : :instance_eval
      object.__send__(m, "def #{method_name}; #{@src}; end", filename || @filename || '(erubis)')
    end


  end


end
