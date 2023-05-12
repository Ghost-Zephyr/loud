
.PHONY: clean

SOOPTS := -shared -nostdlib
OUT := out

test: $(OUT)
	$(CC) $(SOOPTS) pt.s -o $(OUT)/pt.so

build: $(OUT)
	$(CC) $(SOOPTS) loud.s -o $(OUT)/libloud.so

$(OUT):
	mkdir $(OUT)

clean:
	$(RM) -r $(OUT)
