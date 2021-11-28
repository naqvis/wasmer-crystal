require "../src/wasmer"

class AssertionError < RuntimeError
end

def assert
  raise AssertionError.new unless yield
end
