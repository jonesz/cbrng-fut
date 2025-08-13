-- | ignore

import "cbrng"
module SQ = squares32

def is_valid k =
  -- 1) the least significant digit should be odd.
  let cond1 = i64.get_bit 0 k |> (==) 1i32
  -- 2) no 0 digits should be used.
  let cond2 =
    map (\i -> k >> (i * 4) |> (&) 0xF |> (!=) 0x0) (iota (64 / 4)) |> and
  -- 3) the upper 8 digits should be unique.
  -- 4) the lower 8 digits should be unique.
  let cond3_cond4 =
    let hex_idx k z = k >> (z * 4) |> (&) 0xF
    let f k =
      map (\i ->
             map (\j ->
                    if i == j
                    then true
                    else let a = hex_idx k i
                         let b = hex_idx k j
                         in (a != b))
                 (iota 8)
             |> and)
          (iota 8)
      |> and
    let a = f k
    let b = f (k >> 32)
    in and [a, b]
  in and [cond1, cond2, cond3_cond4]

-- ==
-- entry: squares32_invalid
-- input { }
-- output { false }
entry squares32_invalid =
  let a = is_valid 0x0
  let b = is_valid i64.highest
  let c = is_valid 0x1123456789ABCDE
  let d = is_valid 0x123456789ABCCDE
  in [a, b, c, d] |> or

-- ==
-- entry: squares32_construct_valid
-- compiled random input { [1000]i64 }
-- output { true }
entry squares32_construct_valid keys =
  map (SQ.construct) keys |> map (is_valid) |> and
