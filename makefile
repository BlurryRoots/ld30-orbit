all: repack run

repack:
	rm -f ConnecTed.love
	zip -9qr ConnecTed.love *.lua sfx gfx lib map src

run:
	love ConnecTed.love
