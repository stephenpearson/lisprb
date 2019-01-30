class StackFrame
  attr_accessor :symbols, :parent_frame

  def initialize(parent_frame, symbols = {})
    @parent_frame = parent_frame
    @symbols = symbols
  end

  def add(sym, value)
    value = :nil if value == nil
    ptr = self
    while ptr != nil and ptr.symbols[sym] == nil
      ptr = ptr.parent_frame
    end
    if ptr == nil
      addlocal(sym, value)
    else
      ptr.addlocal(sym, value)
    end
    value
  end

  def addlocal(sym, value)
    value = :nil if value == nil
    @symbols[sym] = value
    value
  end

  def lookup(sym)
    ptr = self
    while ptr != nil
      return ptr.symbols[sym] if ptr.symbols[sym]
      ptr = ptr.parent_frame
    end
    nil
  end
end
