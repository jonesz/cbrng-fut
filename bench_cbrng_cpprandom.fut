import "lib/github.com/diku-dk/cpprandom/random"
import "lib/github.com/jonesz/cbrng-fut/cbrng"

module mk_bench_cbrng (T: integral) (K: integral) (E: cbrng_engine with t = T.t with k = K.t) = {
  def bench (k: K.t) (n: i64) =
    let k = E.construct k
    in map (E.rand k) (iota n) |> reduce (T.+) (T.i64 0)
}

module mk_bench_rng (T: integral) (E: rng_engine with t = T.t) = {
  def bench (k: i32) (n: i64) =
    let rngs = E.rng_from_seed [k] |> E.split_rng n
    let (_, xs) = map (E.rand) rngs |> unzip
    in reduce (T.+) (T.i64 0) xs
}

module squares_bench = mk_bench_cbrng u32 i64 squares32
module minstd_rand_bench = mk_bench_rng u32 minstd_rand
module xorshift128plus_bench = mk_bench_rng u64 xorshift128plus

entry squares32 = squares_bench.bench 0xABCDi64
entry minstd_rand = minstd_rand_bench.bench 0xABCDi32
entry xorshift128plus = xorshift128plus_bench.bench 0xABCDi32

-- ==
-- entry: squares32 minstd_rand xorshift128plus
-- compiled input { 1280000i64 }
