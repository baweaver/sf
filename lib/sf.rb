require "sf/version"

module Sf
  VALID_OPERATORS = %i[
    + - * ** % / == [] << >> & |
  ]

  class StackOperation
    def initialize(operations: [])
      # puts "Initial Stack: #{operations}"
      @operations = operations
      @equality_called = false
    end

    def to_proc
      proc { |target| self.call(target) }
    end

    # Super naive for now, proof of concept. Will get order of ops later.
    def call(target)
      # puts "Streamed Target: #{target}"
      # puts "Evaluation Target: '#{target.inspect} #{@operations.join(' ')}'"

      eval("#{target.inspect} #{@operations.join(' ')}")
    end

    alias_method :===, :call
    alias_method :[],  :call

    VALID_OPERATORS.each do |m|
      define_method(m) { |b|
        # Prevent overloading of `==` for too long
        return false if @equality_called
        @equality_called = m == :==

        # puts "Chunk Added: method: #{m}, value: #{b}"
        @operations << m.to_s << b
        # p @operations
        self
      }
    end
  end

  # Because Lazy, fixing later
  class << self
    VALID_OPERATORS.each do |m|
      define_method(m) { |b| StackOperation.new(operations: [m.to_s, b]) }
    end
  end
end
