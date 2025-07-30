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
    with engine.k = K.t
    with num.t = D.t
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
    with engine.k = K.t
    with num.t = R.t
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
    let u1 = E.rand k1 ctr
    let u2 = E.rand k2 ctr
    let u1 = (to_R u1 - to_R E.min) / (to_R E.max - to_R E.min)
    let u2 = (to_R u2 - to_R E.min) / (to_R E.max - to_R E.min)
    let r = sqrt (i32 (-2) * log u1)
    let theta = i32 2 * pi * u2
    in mean + stddev * (r * cos theta)
}
