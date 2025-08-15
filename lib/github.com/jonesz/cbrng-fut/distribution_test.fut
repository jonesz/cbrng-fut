-- | ignore

import "cbrng"
import "distribution"

-- A straight port from `diku-dk/cpprandom/random_tests.fut'.
module mktest_f (dist: cbrng_distribution) (R: real with t = dist.num.t) = {
  module engine = dist.engine
  module num = dist.num

  def test (n: i64) seed (d: dist.distribution) =
    let xs = map (dist.rand seed d) (iota n)
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
  mktest_f (rademacher_distribution f32 u32 SQ) f32

-- ==
-- entry: test_rademacher
-- compiled random input { i64 100i64 } output { 0.0_f32 1.0_f32 }
entry test_rademacher k n =
  test_rademacher_f.test n (SQ.construct k) ()

module test_gaussian_f =
  mktest_f (gaussian_distribution f32 u32 SQ) f32

-- ==
-- entry: test_normal
-- compiled random input { i64 100i64 } output { 0.0_f32 1.0_f32 }
entry test_normal k n =
  test_gaussian_f.test n (SQ.construct k) {mean = 0.0_f32, stddev = 1.0_f32}

-- ==
-- entry: test_gaussian
-- compiled random input { i64 100i64 } output { 5.0_f32 2.0_f32 }
entry test_gaussian k n =
  test_gaussian_f.test n (SQ.construct k) {mean = 5.0_f32, stddev = 2.0_f32}

module test_uniform_f =
  mktest_f (uniform_real_distribution f32 u32 SQ) f32

-- ==
-- entry: test_uniform_real
-- compiled random input { i64 1_000i64 } output { 50.0_f32 }
entry test_uniform_real k n =
  -- TODO: Check the stddev of `uniform_real`.
  -- TODO: Why is this (1, 100) and not (0, 100); taken from the `diku-dk` code?
  let (mean, _stddev) = test_uniform_f.test n (SQ.construct k) {min_r = 1.0_f32, max_r = 100.0_f32}
  in mean
