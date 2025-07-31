import "cbrng"

module type cbrng_distribution = {
  -- | The random number engine underlying this distribution.
  module engine: cbrng_engine

  -- | A module describing the type of vlaes produced by this random distribution.
  module num: numeric

  -- | The dynamic configuration of the distribution.
  type distribution

  -- | Generate a random number given the distribution and counter.
  val rand : distribution -> i64 -> num.t
}

module rademacher_distribution
  (D: numeric)
  (T: integral)
  (K: integral)
  (E: cbrng_engine with t = T.t with k = K.t)
  : cbrng_distribution
    with num.t = D.t
    with engine.k = K.t
    with distribution = K.t = {
  module engine = E
  module num = D

  type distribution = K.t

  def rand d ctr =
    if E.rand d ctr |> T.get_bit 0 |> (==) 1i32
    then D.i32 1i32
    else D.i32 1i32 |> D.neg
}

module gaussian_distribution
  (R: real)
  (T: integral)
  (K: integral)
  (E: cbrng_engine with t = T.t with k = K.t)
  : cbrng_distribution
    with num.t = R.t
    with engine.k = K.t
    with distribution = (K.t, K.t, {mean: R.t, stddev: R.t}) = {
  module engine = E
  module num = R

  type distribution = (K.t, K.t, {mean: R.t, stddev: R.t})

  -- Straight port from `diku-dk/cpprandom/random.fut`.
  def to_R (x: E.t) =
    R.u64 (u64.i64 (T.to_i64 x))

  open R

  def rand (k1, k2, {mean = mean: R.t, stddev = stddev: R.t}) ctr =
    -- Box-Muller where we only use one of the generated points.
    let (u1, u2) =
      let xs = map (flip (E.rand) ctr) [k1, k2] |> map (\u_i -> (to_R u_i - to_R E.min) / (to_R E.max - to_R E.min))
      in (head xs, last xs)
    let r = sqrt (i32 (-2) * log u1)
    let theta = i32 2 * pi * u2
    in mean + stddev * (r * cos theta)
}

module uniform_real_distribution
  (R: real)
  (T: integral)
  (K: integral)
  (E: cbrng_engine with t = T.t with k = K.t)
  : cbrng_distribution
    with num.t = R.t
    with engine.k = K.t
    with distribution = (K.t, {min_r: R.t, max_r: R.t}) = {
  module engine = E
  module num = R

  type distribution = (K.t, {min_r: R.t, max_r: R.t})

  -- Straight port from `diku-dk/cpprandom/random.fut`.
  def to_R (x: E.t) =
    R.u64 (u64.i64 (T.to_i64 x))

  def rand (k: K.t, {min_r = min_r: R.t, max_r = max_r: R.t}) ctr =
    let x = E.rand k ctr
    let x' = R.((to_R x - to_R E.min) / (to_R E.max - to_R E.min))
    in R.(min_r + x' * (max_r - min_r))
}

module uniform_int_distribution
  (D: numeric)
  (T: integral)
  (K: integral)
  (E: cbrng_engine with t = T.t with k = K.t)
  : cbrng_distribution
    with engine.k = K.t
    with num.t = D.t
    with distribution = (K.t, {min_i: D.t, max_i: D.t}) = {
  module engine = E
  module num = D

  type distribution = (K.t, {min_i: D.t, max_i: D.t})

  module UR = uniform_real_distribution f32 T K E

  def rand (k: K.t, {min_i = min_i: D.t, max_i = max_i: D.t}) ctr =
    -- Generate a number between `[0, 1)`, scale it by the range, floor to `{0, ..., N-1}`, then shift by `D_min`.
    (D.-) max_i min_i |> (D.+) (D.i64 1) |> D.to_i64 |> f32.i64
    |> (f32.*) (UR.rand (k, {min_r = 0.0_f32, max_r = 1.0_f32}) ctr)
    |> f32.floor
    |> D.f32
    |> (D.+) min_i
}
