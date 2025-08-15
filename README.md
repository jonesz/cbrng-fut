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

let s = squares32.consruct 0x5EED
let xs = tabulate 100 (squares32.rand s)

-- Sample 100 values from the Rademacher distribution.
module R = rademacher_distribution f32 u32 squares32
let xs = tabulate 100 (R.rand s ())
```
