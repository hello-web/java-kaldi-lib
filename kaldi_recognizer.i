%module kaldi_recognizer

%include <typemaps.i>
%include <std_string.i>
%include <arrays_java.i>

namespace kaldi {
}

%apply signed char[] { const char *data };

%pragma(java) jniclasscode=%{
    static {
        System.loadLibrary("_kaldi_recognizer");
    }
%}

%{
#include "kaldi_recognizer.h"
#include "model.h"
%}
%include "kaldi_recognizer.h"
%include "model.h"

