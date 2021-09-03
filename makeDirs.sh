#!/bin/zsh

# takes every json file in a directory, creates a folder for it and
# moves it into that folder
# this creates a test directory structure that that the atom cql
# extension can access

for filename in *.json;
  do
    shortFilename="$(basename -- "$filename" .json)" ;
    directory=$(echo $shortFilename | cut -d "_" -f 3);
    mkdir $directory;
    mv "$filename" "$directory"
done
