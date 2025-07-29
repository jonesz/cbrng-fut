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
