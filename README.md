# cbrng-fut

**C**ounter-**b**ased pseudo-**r**andom **n**umber **g**eneration in Futhark.

## Installation

```
$ futhark pkg add github.com/jonesz/cbrng-fut
$ futhark pkg sync
```

## Usage

```
import "lib/github.com/jonesz/cbrng-fut/cbrng"
import "lib/github.com/jonesz/cbrng-fut/distribution"

-- Sample 100 values from the Rademacher distribution.
module R = rademacher_distribution f32 u32 i64 squares32
let k = squares32.construct 0x5EED
let xs = map (R.rand k) (iota 100)
```
