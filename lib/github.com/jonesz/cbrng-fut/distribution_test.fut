-- | ignore

import "cbrng"
import "distribution"

-- A straight port from `diku-dk/cpprandom/random_tests.fut'.
module mktest_f (dist: cbrng_distribution) (R: real with t = dist.num.t) = {
  module engine = dist.engine
  module num = dist.num

  def test (n: i64) (d: dist.distribution) =
    let xs = map (dist.rand d) (iota n)
    let mean = num.(reduce (+) (i32 0) xs / i64 n)
    let stddev =
      R.(xs
         |> map (\x -> (x - mean))
         |> map num.((** i32 2))
         |> sum
         |> (/ i64 n)
         |> sqrt)
    in (R.round mean, R.round stddev)
}

module SQ = squares32

module test_rademacher_f =
  mktest_f (rademacher_distribution f32 u32 i64 SQ) f32

-- ==
-- entry: test_rademacher
-- compiled random input { i64 100i64 } output { 0.0_f32 1.0_f32 }
entry test_rademacher k n =
  test_rademacher_f.test n (SQ.construct k)
