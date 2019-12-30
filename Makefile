ATLASLIBS = /usr/lib/libatlas.so.3 /usr/lib/libf77blas.so.3 /usr/lib/libcblas.so.3 /usr/lib/liblapack_atlas.so.3
#ATLASLIBS = /usr/lib/x86_64-linux-gnu/libatlas.so.3 /usr/lib/x86_64-linux-gnu/libf77blas.so.3 /usr/lib/x86_64-linux-gnu/libcblas.so.3 /usr/lib/x86_64-linux-gnu/liblapack_atlas.so.3 -Wl,-rpath=/usr/lib/x86_64-linux-gnu
KALDI_ROOT=/opt/kaldi
JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
CXX := g++
MKLROOT= /opt/intel/compilers_and_libraries_2019.2.187/linux/mkl
KALDI_FLAGS := \
	-DKALDI_DOUBLEPRECISION=0 -DHAVE_POSIX_MEMALIGN \
	-Wno-sign-compare -Wno-unused-local-typedefs -Winit-self \
	-DHAVE_EXECINFO_H=1 -rdynamic -DHAVE_CXXABI_H -DHAVE_ATLAS \
	-I$(KALDI_ROOT)/tools/ATLAS/include \
	-I$(KALDI_ROOT)/tools/openfst/include -I$(KALDI_ROOT)/src \
	-I${JAVA_HOME}/include -I${JAVA_HOME}/include/linux

CXXFLAGS := -std=c++11 -g -Wall -DPIC -fPIC $(KALDI_FLAGS)

BUILD_DIR = $(PWD)
DEST_DIR = /usr/lib

COPY_FILES = $(DEST_DIR)/lib_kaldi_recognizer.so

KALDI_LIBS = \
	-rdynamic -Wl,-rpath=$(KALDI_ROOT)/tools/openfst/lib \
	$(KALDI_ROOT)/src/online2/kaldi-online2.a \
	$(KALDI_ROOT)/src/decoder/kaldi-decoder.a \
	$(KALDI_ROOT)/src/ivector/kaldi-ivector.a \
	$(KALDI_ROOT)/src/gmm/kaldi-gmm.a \
	$(KALDI_ROOT)/src/nnet3/kaldi-nnet3.a \
	$(KALDI_ROOT)/src/tree/kaldi-tree.a \
	$(KALDI_ROOT)/src/feat/kaldi-feat.a \
	$(KALDI_ROOT)/src/lat/kaldi-lat.a \
	$(KALDI_ROOT)/src/hmm/kaldi-hmm.a \
	$(KALDI_ROOT)/src/transform/kaldi-transform.a \
	$(KALDI_ROOT)/src/cudamatrix/kaldi-cudamatrix.a \
	$(KALDI_ROOT)/src/matrix/kaldi-matrix.a \
	$(KALDI_ROOT)/src/fstext/kaldi-fstext.a \
	$(KALDI_ROOT)/src/util/kaldi-util.a \
	$(KALDI_ROOT)/src/base/kaldi-base.a \
	-L $(KALDI_ROOT)/tools/openfst/lib -lfst \
	$(ATLASLIBS) \
	-lm -lpthread

all: lib_kaldi_recognizer.so

copy: $(COPY_FILES)

$(DEST_DIR)/%.so: $(BUILD_DIR)/%.so
	sudo cp -f $< $@

lib_kaldi_recognizer.so: kaldi_recognizer_wrap.cc kaldi_recognizer.cc model.cc
	$(CXX) $(CXXFLAGS) -shared -o $@ kaldi_recognizer.cc model.cc kaldi_recognizer_wrap.cc $(KALDI_LIBS)

kaldi_recognizer_wrap.cc: kaldi_recognizer.i
	swig -java -package l2m.fonetic.web.model.kaldilib -c++ -o kaldi_recognizer_wrap.cc kaldi_recognizer.i

clean:
	$(RM) *.so kaldi_recognizer_wrap.cc *.o kaldi_recognizer.java kaldi_recognizerJNI.java KaldiRecognizer.java KaldiModel.java
