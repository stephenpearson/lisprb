class Cons
  attr_accessor :car, :cdr

  def initialize(car, cdr)
    @car = car
    @cdr = cdr
  end

  def add(item)
    ptr = self
    while ptr.cdr != nil
      ptr = ptr.cdr
    end
    ptr.cdr = Cons.new(item, nil)
  end

  def to_s
    "( " + _to_s
  end

  def _to_s
    result = []
    if car.kind_of? Cons
      result << "(" << car._to_s
    else
      result << car.to_s
    end

    if cdr == nil or cdr == :nil
      result << ")"
    elsif cdr.kind_of? Cons
      result << cdr._to_s
    else
      result << "." << cdr.to_s << ")"
    end
    result.join(" ")
  end

  def debug(indent = 0)
    spaces = ' ' * indent
    result = "#{spaces}<Cons car="

    if car.kind_of? Cons
      result += "\n" + car.debug(indent + 3)
    else
      result += "#{car.inspect}\n"
    end

    result += "#{spaces}      cdr="
    if cdr.kind_of? Cons
      result += "\n" + cdr.debug(indent + 3)
    else
      result += "#{cdr.inspect}\n"
    end

    result
  end
end
