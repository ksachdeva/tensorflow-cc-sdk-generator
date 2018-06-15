#!/bin/bash

# This script is model after the include folder in the python site-packages/tensorflow

#abort on error
set -e

function usage
{
    echo "usage: gen_tensorflow_sdk -r REPO_DIR -o SDK_DIR [-h]"
    echo "   ";
    echo "  -r | --repo_dir          : Path to the git repo of tensorflow";
    echo "  -o | --sdk_dir           : Path to the output directory";
    echo "  -h | --help              : This message";
}

function parse_args
{
  # positional args
  args=()

  # named args
  while [ "$1" != "" ]; do
      case "$1" in
          -r | --repo_dir )             REPO_DIR="$2";    shift;;
          -o | --sdk_dir )              SDK_DIR="$2";     shift;;          
          -h | --help )                 usage;            exit;; # quit and show usage
          * )                           args+=("$1")      # if no match, add it to the positional args
      esac
      shift # move to next kv pair
  done

  # restore positional args
  set -- "${args[@]}"  

  # validate required args
  if [[ -z "${REPO_DIR}" || -z "${SDK_DIR}" ]]; then
      echo "Invalid arguments"
      usage
      exit;
  fi  
}

function createSDK() 
{
    # create necessay directories if they do not exist
    mkdir -p $SDK_DIR
    mkdir -p $SDK_DIR/include
    mkdir -p $SDK_DIR/libs
    mkdir -p $SDK_DIR/include/tensorflow
    mkdir -p $SDK_DIR/include/tensorflow/core/framework
    mkdir -p $SDK_DIR/include/tensorflow/core/lib/core
    mkdir -p $SDK_DIR/include/tensorflow/core/protobuf
    mkdir -p $SDK_DIR/include/tensorflow/core/util
    mkdir -p $SDK_DIR/include/tensorflow/cc/ops
    mkdir -p $SDK_DIR/include/third_party/eigen3
    mkdir -p $SDK_DIR/include/unsupported
    mkdir -p $SDK_DIR/include/external
    mkdir -p $SDK_DIR/include/Eigen
    mkdir -p $SDK_DIR/include/external/eigen_archive
    mkdir -p $SDK_DIR/include/external/eigen_archive/Eigen
    mkdir -p $SDK_DIR/include/external/eigen_archive/unsupported

    echo "Copying the libraries .."

    # copy/sync the libs
    rsync $REPO_DIR/bazel-bin/tensorflow/{libtensorflow_cc.so,libtensorflow_framework.so} $SDK_DIR/libs

    echo "Copying the headers .."

    # copy/sync the main directory (need to figure out if there is a better option than this)
    rsync -r $REPO_DIR/tensorflow $SDK_DIR/include/

    # remove everything except for .h files
    find $SDK_DIR/include/tensorflow -type f  ! -name "*.h" -delete

    # remove empty directories
    find $SDK_DIR/include/tensorflow -type d -empty -delete

    # handle auto-generated files
    rsync $REPO_DIR/bazel-genfiles/tensorflow/core/framework/*.h  $SDK_DIR/include/tensorflow/core/framework
    rsync $REPO_DIR/bazel-genfiles/tensorflow/core/lib/core/*.h  $SDK_DIR/include/tensorflow/core/lib/core
    rsync $REPO_DIR/bazel-genfiles/tensorflow/core/protobuf/*.h  $SDK_DIR/include/tensorflow/core/protobuf
    rsync $REPO_DIR/bazel-genfiles/tensorflow/core/util/*.h  $SDK_DIR/include/tensorflow/core/util
    rsync $REPO_DIR/bazel-genfiles/tensorflow/cc/ops/*.h  $SDK_DIR/include/tensorflow/cc/ops

    # copy eigen stuff
    # it is copied multiple times at multiple locations
    rsync -r $REPO_DIR/third_party/eigen3 $SDK_DIR/include/third_party
    rsync -r --copy-links $REPO_DIR/bazel-tensorflow/external/eigen_archive/unsupported $SDK_DIR/include/external/eigen_archive/
    rsync -r --copy-links $REPO_DIR/bazel-tensorflow/external/eigen_archive/Eigen $SDK_DIR/include/external/eigen_archive/
    rsync -r --copy-links $REPO_DIR/bazel-tensorflow/external/eigen_archive/unsupported $SDK_DIR/include/
    rsync -r --copy-links $REPO_DIR/bazel-tensorflow/external/eigen_archive/Eigen $SDK_DIR/include/
}

function run
{
  parse_args "$@"

  echo "Supplied arguments are .."  
  echo "REPO_DIR: $REPO_DIR"
  echo "SDK_DIR: $SDK_DIR"

  createSDK

  echo "Copying CMakeLists.txt .."

  cp cmake.template $SDK_DIR/CMakeLists.txt

  echo "All done !"
}

run "$@";