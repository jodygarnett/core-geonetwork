ANZMEST GA Fork
---------------

ANZMEST GA Fork is a fork if ANZMEST https://github.com/anzmest for Geoscience Australia.

When you clone ANZMEST GA fork select the 2.10.x branch eg:

git clone https://github.com/geonetwork-ga/core-geonetwork.git -b 2.10.x --recursive

To build after you have cloned:

```
cd gast
git checkout 2.10.x
git pull
cd ..

cd geoserver
git checkout 2.10.x
git pull
cd ..

cd nationalmap
git checkout master
git pull
cd ..

cd nationalmap/third_party/cesium
git checkout nm
git pull
cd ../../..

cd schemaPlugins
git checkout 2.10.x
git pull
cd ..
```
