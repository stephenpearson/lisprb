#!/usr/bin/env ruby

folder = File.join(File.expand_path('.', __dir__), 'lib')
$:.unshift(folder) unless $:.include?(folder)

require 'lisp_parser'
require 'lisp_eval'

lp = LispParser.new(File.read(ARGV[0]))
prog = lp.parse

le = LispEval.new
le.leval(prog)
