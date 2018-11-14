#!/bin/bash

set -e

hg clone http://hg.openjdk.java.net/jdk8/jdk8/langtools langtools
cd langtools

for i in $(grep -r -l 'System.exit' src/share/classes); do
  sed -i -e 's/System.exit/if (true) { throw new SecurityException(); }; String.valueOf/g' $i
  echo "Patched: $i"
done

ant -buildfile make/build.xml -Dboot.java.home=${JAVA_HOME} build-bootstrap-tools

cd ../

git clone --depth=1 https://github.com/JakeWharton/dalvik-dx.git
cd dalvik-dx
git submodule init
git submodule update

shopt -s globstar

for i in $(grep -r -l 'System.exit' platform_dalvik/dx/src); do
  sed -i -e 's/System.exit/if (true) { throw new SecurityException(); }; String.valueOf/g' $i
  echo "Patched: $i"
done

mvn install -DskipTests=true -Dmaven.javadoc.skip=true
cp target/*.jar ../langtools/build/bootstrap/lib

cd ../
