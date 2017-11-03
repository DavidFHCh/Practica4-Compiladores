cc = gcc
CFLAGS = `pkg-config --cflags --libs glib-2.0`
BIN = bin

$(BIN)/p4: src/main.c
	@mkdir -p $(@D)
	$(cc) $<  -o $@ $(CFLAGS)

run: $(BIN)/p4
	./$<

clean: 
	rm $(BIN) -rf
