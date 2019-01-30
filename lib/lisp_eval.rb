require 'stack_frame'

class LispEval
  DEBUG = false

  def initialize
    root_table = StackFrame.new(nil, {
      exit: lambda {|a| exit(leval(a.car))},
      quote: lambda {|a| a.car},
      eval: lambda {|a| leval(leval(a.car))},
      cons: lambda {|a| Cons.new(leval(a.car), leval(a.cdr.car))},
      car: lambda {|a| acar = leval(a.car); acar == :nil ? :nil : acar.car},
      cdr: lambda {|a| acar = leval(a.car); acar == :nil ? :nil : acar.cdr},
      progn: lambda do |a|
        save = @framepointer
        @framepointer = StackFrame.new(save, {})
        iterlist(a) {|ptr| leval(ptr.car)}
        @framepointer = save
      end,
      println: lambda {|a| iterlist(a) {|ptr| puts(leval(ptr.car))}},
      print: lambda {|a| iterlist(a) {|ptr| print(leval(ptr.car))}},
      plus: lambda {|a| reduce_list(a, 0, :+)},
      minus: lambda {|a| leval(a.car) - leval(a.cdr.car)},
      times: lambda {|a| reduce_list(a, 1, :*)},
      div: lambda {|a| reduce_list(a.cdr, leval(a.car), :/)},
      equal: lambda {|a| leval(a.car) == leval(a.cdr.car)},
      not: lambda {|a| not leval(a.car)},
      str: lambda {|a| leval(a.car).to_s},
      gt: lambda {|a| leval(a.car) > leval(a.cdr.car)},
      lt: lambda {|a| leval(a.car) < leval(a.cdr.car)},
      if: lambda {|a| leval(a.car) ? leval(a.cdr.car) : (a.cdr.cdr != nil ? leval(a.cdr.cdr.car) : nil)},
      empty: lambda {|a| v = leval(a.car); v == nil or v == :nil ? true : false},
      set: lambda {|a| var = leval(a.car); val = leval(a.cdr.car); @framepointer.add(var, val); val},
      setnth: lambda do |a|
        ls = leval(a.car)
        n = leval(a.cdr.car)
        val = leval(a.cdr.cdr.car)
        n.times do
          ls = ls.cdr
          return if ls == nil or ls == :nil
        end
        ls.car = val if ls != nil and ls != :nil
      end,
      local: lambda {|a| var = leval(a.car); val = leval(a.cdr.car); @framepointer.addlocal(var, val); val},
      return: lambda {|a| leval(a.car)},
      defun: lambda do |a|
        name = a.car
        params = a.cdr.car
        body = a.cdr.cdr
        @framepointer.addlocal(name, lambda do |p|
          puts "Calling fn name = #{name}" if DEBUG
          save = @framepointer
          newfp = StackFrame.new(save, {})
          ptr = params
          while ptr != nil and ptr.car != nil do
            newfp.addlocal(ptr.car, leval(p.car))
            ptr = ptr.cdr
            p = p.cdr
          end
          @framepointer = newfp
          puts "symbols = #{@framepointer.symbols}" if DEBUG
          ptr = body
          while ptr != nil do
            ret = leval(ptr.car)
            break if ptr.car == :return
            ptr = ptr.cdr
          end
          @framepointer = save
          ret
        end)
      end
    })
    @framepointer = root_table
  end

  def reduce_list(a, init, fn)
    sum = init
    iterlist(a) do |ptr|
      sum = sum.send(fn, leval(ptr.car))
    end
    sum
  end

  def iterlist(ptr)
    while ptr != nil do
      ret = yield ptr
      ptr = ptr.cdr
    end
    ret
  end

  def leval(prog, fp=nil)
    fp = @framepointer if fp == nil
    puts "leval: #{prog}" if DEBUG
    return :nil if prog == nil or prog == :nil
    if prog.kind_of? Cons
      return :nil if prog.car == nil and prog.cdr == nil
      fn = fp.lookup(prog.car)
      raise "Invalid function \"#{fn}\"" unless fn.kind_of? Proc
      puts "prog.cdr params = #{prog.cdr}" if DEBUG
      ret = fn.yield(prog.cdr)
      puts "ret from #{prog.car} = #{ret}" if DEBUG
      ret
    elsif prog.kind_of? Symbol
      result = fp.lookup(prog)
      raise "Unknown symbol #{prog}" unless result
      puts "value = #{result}" if DEBUG
      return result
    else
      return prog
    end
  end
end
