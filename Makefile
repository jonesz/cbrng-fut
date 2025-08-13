SRC = \
	 lib/github.com/jonesz/cbrng-fut/cbrng.fut \
	 lib/github.com/jonesz/cbrng-fut/distribution.fut

TEST = \
	lib/github.com/jonesz/cbrng-fut/cbrng_test.fut \
	lib/github.com/jonesz/cbrng-fut/distribution_test.fut

test: $(TEST)
	futhark test $^

bench: bench_cbrng_cpprandom.fut $(SRC)
	futhark bench --backend=multicore $<

.PHONY: clean test

clean:
	$(RM) lib/github.com/jonesz/cbrng-fut/*.c
	$(RM) lib/github.com/jonesz/cbrng-fut/*.actual
	$(RM) lib/github.com/jonesz/cbrng-fut/*.expected
	$(RM) lib/github.com/jonesz/cbrng-fut/distribution_test
	$(RM) lib/github.com/jonesz/cbrng-fut/cbrng_test
	$(RM) bench_cbrng_cpprandom
	$(RM) bench_cbrng_cpprandom.c
