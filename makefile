name = OrBit

all: repack run

repack:
	rm -f $(name).love
	zip -9qr $(name).love *.lua sfx gfx lib map src

run:
	love $(name).love

publish: repack
	mv $(name).love ~/Documents/Dropbox/LD30
