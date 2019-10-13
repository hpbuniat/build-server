#!/bin/bash
cd $PWD/build/ &&
  composer update -o &&
  php vendor/bin/robo install