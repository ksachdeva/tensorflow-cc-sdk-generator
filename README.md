# Tensorflow C++ SDK Generator

## Overview

It is quite strange that a project of status like tensorflow does not provide an offically generated development package.

Here is an attempt to generate a *sort* of SDK. I have made few assumptions and the directory structure of the generated SDK is based
on the *include* folder that ships with the tensorflow python package.

## Building tensorflow on your machine

This is well documented here -
[https://www.tensorflow.org/install/install_sources](https://www.tensorflow.org/install/install_sources)

## Generate the SDK

You need to provide two arguments to the script (gen_sdk.sh) 

* The path to the tensorflow github repository that you cloned
* The path where you want to generate the SDK

Here is an example command -

```bash
./gen_sdk.sh -r ~/Desktop/Dev/3rdparty-compiled/tensorflow -o example/third-party/tensorflow-sdk
```

The tensorflow-sdk contains 3 main items -:

* *include* directory that contains the header files
* *libs* directory that contains libtensorflow_cc.so & libtensorflow_framework.so shared libraries
* *CMakeLists.txt* file that exposes an INTERFACE only CMake module with an alias *third-party::tensorflow-cc*

## Example usage

The *example* folder contains a project structure that I generally use. Notice that the above example generation command created the SDK
in the example/third-party folder.

This example project uses CMake as a build system.

Here are the steps to compile it -:

```bash
# traditional cmake based build
cd example
mkdir build
cd build
cmake ..
cmake --build .
```

Running the sample application -

Since the tensorflow shared libraries are not in the path you would have to either move them in /usr/local/lib or
update your LD_LIBRARY_PATH environment variable.

```bash
# set LD_LIBRARY_PATH
export LD_LIBRARY_PATH=<full_path_to_repo>/example/third-party/tensorflow-sdk/libs
```

```bash
# run it
cd build
./example
```
