using XLA, Test

double = xla(x -> x + x)

@test double(21) == 42
@test double(4.5) == 9.0

let x = 2, y = 2.0
  @test_broken xla(() -> x+y) == 4.0
end

add(a, b) = a+b
@test @code_xla(add(2, 3)) isa XLA.IR

@test xla(() -> 2+2)() == 4

let x = 5
  @test xla(() -> 3x^(1+1) + (2x + 1))() == 86
end

relu = xla(x -> x > 0 ? x : 0)

@test relu(5) == 5
@test relu(-5) == 0
@test_broken relu(5.0) == 5.0

let x = rand(3), y = rand(3)
  @test collect(xla(() -> x+y)()) == x+y
end

function updatezero!(env)
  if env[:x] < 0
    env[:x] = 0
  end
end

relu = xla() do x
  env = Dict()
  env[:x] = x
  updatezero!(env)
  return env[:x]
end

@test relu(5) == 5
@test relu(-5) == 0
