zip -r zrm2d.love main.lua conf.lua ./src ./gfx
cat ./love-0.9.2-win64/love.exe ./zrm2d.love > ./build/zrm2d.exe
zip -r zrm2d.zip ./build
