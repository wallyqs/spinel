# Constants a multiple assignment writes, whose names another class's
# constants share: the qualifying pass gives each its own slot
# (cst_M__Foo__CENTER), but the passes that type the targets looked the
# slot up by the bare name, found none, and left it untyped and
# undeclared; reads raised NameError and the C compile failed on the
# stores (use of undeclared identifier 'cst_M__Foo__CENTER').
module M
  class FlexStyle
    START, FLEX_END, CENTER = 0, 1, 2
    NOWRAP, WRAP = 0, 1
  end
  class TextAlign
    LEFT, CENTER, RIGHT = 0, 1, 2
  end
  module WhiteSpace
    NORMAL, NOWRAP = 0, 1
  end
  class Font
    NORMAL, ITALIC = "normal", "italic"
  end
end
p M::FlexStyle::CENTER, M::TextAlign::CENTER
p M::FlexStyle::NOWRAP, M::WhiteSpace::NOWRAP
p M::WhiteSpace::NORMAL, M::Font::NORMAL, M::Font::ITALIC
p M::FlexStyle::START, M::TextAlign::RIGHT

def pair = [10, 20]
class A
  X, Y = Object.new.then { [:a, :b] }
end
class B
  X, Y = pair
end
p A::X, A::Y, B::X, B::Y

class C1
  ONE, TWO = 1
end
class C2
  ONE, TWO = "one"
end
p C1::ONE, C1::TWO, C2::ONE, C2::TWO

class D1
  *REST, LAST = 1, 2, 3
end
class D2
  *REST, LAST = :x, :y
end
p D1::REST, D1::LAST, D2::REST, D2::LAST

module P; end
module Q; end
P::K, Q::K = 3.5, "k"
p P::K, Q::K
