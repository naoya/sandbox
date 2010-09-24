#!/usr/bin/ruby

class Trie
  def encode(char)
    l = 0
    u = @code.length - 1
    while (l char
           u = m - 1
         elsif @code < char
           l = m + 1
         else
           return m + 1
         end
end
return -1
end

def initialize(file)
@base = <1>
@check = <0>
@code = Array.new
words = Array.new
io = open(file)
while line = io.gets
line.chomp!
words.push(line)
  line.each_byte {|c| @code = c }
end
io.close
words.sort!
@code.compact!
_search(0, 0, words.length, 0, words)
end

def match(word)
check = 0
base = @base
word.each_byte do |c|
i = base + encode(c)
if (@check != check)
break
end
base = @base
check = i
end
return @check == check
end

def _search(i, l, u, parent, words)
stack = Array.new
tmp = Array.new
sons = Array.new
j = l
p = nil
while j < u
word = words
if i 0)
base = 0
flag = 0
begin
base += 1
tmp.each do |c|
break if (@check != nil)
flag += 1
end
end while flag != tmp.length
tmp.each do |c|
@base = base
son = base + c
@check = parent
@base = - 1 if c == 0
sons.push(son)
end
end
stack.push(j)
l = stack.shift
if stack.length > 0
i += 1
(stack.length).times do
u = stack.shift
son = sons.shift
_search(i, l, u, son, words)
l = u
end
end
end
end
