class LispParser
  require 'cons'
  require 'strscan'

  def initialize(string)
    @stream = StringScanner.new(string)
  end

  def parse
    @stream.skip /\s+/
    if @stream.check(/\(/) == '('
      # List
      return parse_list
    elsif symbol = @stream.scan(/[a-zA-Z_]{1}[a-zA-Z0-9_]*/)
      # Symbol
      return symbol.to_sym
    elsif number = @stream.scan(/[0-9]+/)
      # Integer
      return number.to_i
    elsif @stream.scan(/"/)
      # String
      str = @stream.scan(/[^"]*/)
      @stream.scan(/"/)
      return str
    else
      raise "SyntaxError"
    end
  end

  def parse_list
    @stream.skip /\s+/
    raise "SyntaxError" unless @stream.scan(/\(/)
    @stream.skip /\s+/

    # Is this an empty list?
    if @stream.scan(/\)/)
      return :nil
    end

    # Get first entry
    car = parse()
    @stream.skip /\s+/

    # Is this a single element list?
    if @stream.scan(/\)/)
      return Cons.new(car, nil)
    end

    # Is this a cons cell?
    if @stream.scan(/\./)
      cdr = parse()
      @stream.skip /\s+/
      raise "SyntaxError" unless @stream.scan(/\)/)
      return Cons.new(car, cdr)
    end

    # Else this is an artibrary length list
    result = Cons.new(car, nil)
    ptr = result
    while @stream.check(/\)/) == nil do
      ptr.cdr = Cons.new(parse(), nil)
      ptr = ptr.cdr
      @stream.skip /\s+/
    end
    raise "SyntaxError" unless @stream.scan(/\)/)
    result
  end
end
