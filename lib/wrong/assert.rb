require "predicated/predicate"
require "predicated/from/ruby_code_string"
require "predicated/to/sentence"
require "wrong/chunk"
require "wrong/config"

#see http://yehudakatz.com/2009/01/18/other-ways-to-wrap-a-method/
class Module
  def overridable(&blk)
    mod = Module.new(&blk)
    include mod
  end
end

module Wrong
  module Assert

    class AssertionFailedError < RuntimeError;
    end

    def failure_class
      AssertionFailedError
    end

    # Actual signature: assert(explanation = nil, depth = 0, block)
    def assert(*args, &block)
      if block.nil?
        begin
          super
        rescue NoMethodError => e
          # note: we're not raising an AssertionFailedError because this is a programmer error, not a failed assertion
          raise "You must pass a block to Wrong's assert and deny methods"
        end
      else
        aver(:assert, *args, &block)
      end
    end

    # Actual signature: deny(explanation = nil, depth = 0, block)    
    def deny(*args, &block)
      if block.nil?
        test = args.first
        msg = args[1]
        assert !test, msg  # this makes it get passed up to the framework
      else
        aver(:deny, *args, &block)
      end
    end

    def rescuing
      error = nil
      begin
        yield
      rescue Exception, RuntimeError => e
        error = e
      end
      error
    end

    # Usage:
    # capturing { puts "hi" } => "hi\n"
    # capturing(:stderr) { $stderr.puts "hi" } => "hi\n"
    # out, err = capturing(:stdout, :stderr) { ... }
    #
    # see http://www.justskins.com/forums/closing-stderr-105096.html for more explanation
    def capturing(*streams)
      streams = [:stdout] if streams.empty?
      original = {}
      captured = {}

      # reassign the $ variable (which is used by well-behaved code e.g. puts)
      streams.each do |stream|
        original[stream] = (stream == :stdout ? $stdout : $stderr)
        captured[stream] = StringIO.new
        case stream
          when :stdout
            $stdout = captured[stream]
          when :stderr
            $stderr = captured[stream]
        end
      end

      yield

      # return either one string, or an array of two strings
      if streams.size == 1
        captured[streams.first].string
      else
        [captured[streams[0]].string, captured[streams[1]].string]
      end

    ensure

      streams.each do |stream|
        # bail if stream was reassigned inside the block
        if (stream == :stdout ? $stdout : $stderr) != captured[stream]
          raise "#{stream} was reassigned while being captured"
        end
        # support nested calls to capturing
        original[stream] << captured[stream].string if original[stream].is_a? StringIO
        case stream
          when :stdout
            $stdout = original[stream]
          when :stderr
            $stderr = original[stream]
        end
      end
    end

    overridable do
      def failure_message(method_sym, block, predicate)
        method_sym == :deny ? predicate.to_sentence : predicate.to_negative_sentence
      end
    end

    private

    def aver(valence, explanation = nil, depth = 0, &block)
      require "wrong/rainbow" if Wrong.config[:color]
      
      value = block.call
      value = !value if valence == :deny
      unless value
        chunk = Wrong::Chunk.from_block(block, depth + 2)
        code = chunk.code

        predicate = begin
          Predicated::Predicate.from_ruby_code_string(code, block.binding)
        rescue Predicated::Predicate::DontKnowWhatToDoWithThisSexpError
          nil
        rescue Exception
          nil
        end

        code = code.color(:blue) if Wrong.config[:color]
        message = ""
        message << "#{explanation}: " if explanation
        message << "#{valence == :deny ? "Didn't expect" : "Expected"} #{code}, but "
        if predicate && !(predicate.is_a? Predicated::Conjunction) 
          failure = failure_message(valence, block, predicate)
          failure = failure.bold if Wrong.config[:color] 
          message << failure
        end
        message << chunk.details
        raise failure_class.new(message)
      end
    end
  end

end
