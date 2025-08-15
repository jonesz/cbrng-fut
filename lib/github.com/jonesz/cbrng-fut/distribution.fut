import "cbrng"

module type cbrng_distribution = {
  -- | The random number engine underlying this distribution.
  module engine: cbrng_engine

  -- | A module describing the type of values produced by this random distribution.
  module num: numeric

  -- | The seed utilized for this distribution.
  type seed

  -- | The dynamic configuration of the distribution.
  type distribution

  -- | Generate a random number given a seed, a distribution, and a counter.
  val rand : seed -> distribution -> i64 -> num.t
}

module rademacher_distribution
  (D: numeric)
  (T: integral)
  (E: cbrng_engine with t = T.t)
  : cbrng_distribution
    with seed = E.k
    with num.t = D.t
    with distribution = () = {
  module engine = E
  module num = D

  type seed = E.k
  type distribution = ()

  def rand seed _ ctr =
    if E.rand seed ctr |> T.get_bit 0 |> (==) 1i32
    then D.i32 1i32
    else D.i32 1i32 |> D.neg
}

module gaussian_distribution
  (R: real)
  (T: integral)
  (E: cbrng_engine with t = T.t)
  : cbrng_distribution
    with seed = E.k
    with num.t = R.t
    with distribution = {mean: R.t, stddev: R.t} = {
  module engine = E
  module num = R

  type seed = E.k
  type distribution = {mean: R.t, stddev: R.t}

  -- Straight port from `diku-dk/cpprandom/random.fut`.
  def to_R (x: E.t) =
    R.u64 (u64.i64 (T.to_i64 x))

  def rand seed {mean = mean: R.t, stddev = stddev: R.t} (ctr: i64) =
    -- Box-Muller where we only use one of the generated points.
    let neg_ctr = (i64.neg) ctr
    let (u1, u2) =
      -- These CBRNGs are likely called with `tabulate` or `map (f) (iota n)` -- that is, the `ctr` value
      -- is an `i64`, but we only use [0, n]; we can get a second random point from negating the ctr...
      let xs = map (E.rand seed) [ctr, neg_ctr] |> map (\u_i -> (to_R u_i R.- to_R E.min) R./ (to_R E.max R.- to_R E.min))
      in (head xs, last xs)
    let r = R.sqrt (R.i32 (-2) R.* R.log u1)
    let theta = R.i32 2 R.* R.pi R.* u2
    in mean R.+ stddev R.* (r R.* R.cos theta)
}

module uniform_real_distribution
  (R: real)
  (T: integral)
  (E: cbrng_engine with t = T.t)
  : cbrng_distribution
    with seed = E.k
    with num.t = R.t
    with distribution = {min_r: R.t, max_r: R.t} = {
  module engine = E
  module num = R

  type seed = E.k
  type distribution = {min_r: R.t, max_r: R.t}

  -- Straight port from `diku-dk/cpprandom/random.fut`.
  def to_R (x: E.t) =
    R.u64 (u64.i64 (T.to_i64 x))

  def rand seed {min_r = min_r: R.t, max_r = max_r: R.t} ctr =
    let x = E.rand seed ctr
    let x' = R.((to_R x - to_R E.min) / (to_R E.max - to_R E.min))
    in R.(min_r + x' * (max_r - min_r))
}

module uniform_int_distribution
  (D: numeric)
  (T: integral)
  (E: cbrng_engine with t = T.t)
  : cbrng_distribution
    with seed = E.k
    with num.t = D.t
    with distribution = {min_i: D.t, max_i: D.t} = {
  module engine = E
  module num = D

  type seed = E.k
  type distribution = {min_i: D.t, max_i: D.t}
  module UR = uniform_real_distribution f32 T E

  def rand (seed: E.k) {min_i = min_i: D.t, max_i = max_i: D.t} ctr =
    -- Generate a number between `[0, 1)`, scale it by the range, floor to `{0, ..., N-1}`, then shift by `D_min`.
    (D.-) max_i min_i |> (D.+) (D.i64 1) |> D.to_i64 |> f32.i64
    |> (f32.*) (UR.rand seed {min_r = 0.0_f32, max_r = 1.0_f32} ctr)
    |> f32.floor
    |> D.f32
    |> (D.+) min_i
}
