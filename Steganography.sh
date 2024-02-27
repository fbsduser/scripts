# Encode
cat test | ./lvdoenc -s 640x480 -q 6 --qmin 1 --qmax 4 | x264 --input-res 640x480 --fps 1 --profile high --level 5.1 --tune stillimage --crf 22 --colormatrix bt709 --me dia --merange 0 -o 720p.h264.mp4 -

# Decode
ffmpeg -i 720p.h264.mp4 -r 1 -f rawvideo - | ./lvdodec -s 640x480 -q 6 --qmin 1 --qmax 4 | mplayer -

#### You can hide your message inside of a movie ! ! ! ... Be happy :D
