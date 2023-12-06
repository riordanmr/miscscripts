pushd web/images/$1
for file in *.jpg; do
   convert $file -resize 200x200 thumbs/$file
done
popd
