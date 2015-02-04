name = OrBit

all: repack run

repack:
	rm -f $(name).love
	zip -9qr $(name).love *.lua sfx gfx lib map src

run:
	love $(name).love

build-win: build-win32 build-win64
	mv win32.zip ~/Documents/Dropbox/Public/OrBit.win32.zip
	mv win64.zip ~/Documents/Dropbox/Public/OrBit.win64.zip

build-win32: repack
	rm -rf dist/32
	mkdir dist/32
	cp dist/love-0.9.1-win32/* dist/32
	cat dist/32/love.exe $(name).love > dist/32/$(name).exe
	rm dist/32/love.exe
	zip -9qr win32.zip dist/32

build-win64: repack
	rm -rf dist/64
	mkdir dist/64
	cp dist/love-0.9.1-win64/* dist/64
	cat dist/64/love.exe $(name).love > dist/64/$(name).exe
	rm dist/64/love.exe
	zip -9qr win64.zip dist/64

publish: repack
	cp $(name).love ~/Documents/Dropbox/Public

