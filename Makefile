SRC = \
	 lib/github.com/jonesz/cbrng-fut/cbrng.fut \
	 lib/github.com/jonesz/cbrng-fut/distribution.fut

TEST = \
	lib/github.com/jonesz/cbrng-fut/distribution_test.fut

test: $(TEST) $(SRC)
	futhark test $<

bench: bench_cbrng_cpprandom.fut $(SRC)
	futhark bench $<

.PHONY: clean

clean:
	$(RM) lib/github.com/jonesz/cbrng-fut/*.c
	$(RM) lib/github.com/jonesz/cbrng-fut/*.actual
	$(RM) lib/github.com/jonesz/cbrng-fut/*.expected
	$(RM) lib/github.com/jonesz/cbrng-fut/distribution_test
	$(RM) bench_cbrng_cpprandom
	$(RM) bench_cbrng_cpprandom.c
