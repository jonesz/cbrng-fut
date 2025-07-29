SRC = \
	 lib/github.com/jonesz/cbrng-fut/cbrng.fut \
	 lib/github.com/jonesz/cbrng-fut/distribution.fut

TEST = \
	lib/github.com/jonesz/cbrng-fut/distribution_test.fut

test: $(SRC) $(TEST)
	futhark test $(TEST)

.PHONY: clean

clean:
	$(RM) lib/github.com/jonesz/cbrng-fut/*.c
	$(RM) lib/github.com/jonesz/cbrng-fut/*.actual
	$(RM) lib/github.com/jonesz/cbrng-fut/*.expected
	$(RM) lib/github.com/jonesz/cbrng-fut/distribution_test
	
