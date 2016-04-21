%WINDOW   Design an FIR filter using the windowed impulse response method.
%   H = WINDOW(D, FCNHNDL, FCNARG) designs an FIR filter using the
%   specifications in D.  
%   
%   H will be either a single-rate digital filter, DFILT, or a multirate
%   digital filter, MFILT, depending on the specification type D.
%
%   FCNHNDL is a handle to a function that returns a window vector.  FCNARG
%   is an optional argument that can be passed in to the function that
%   returns a window.  See example 1 below for such a case.
%
%   H = WINDOW(D, WIN) designs a filter using the vector in WIN. The vector
%   must have the same length as the impulse response of the filter, i.e.
%   it must correspond to the filter order plus one.
%
%   % Example #1, use a function handle and optional parameters:
%   h = fdesign.decim(4,'pl',14);
%   Hm = window(h,@kaiser,2.5);
%
%   % Example #2, use a window vector:
%   h = fdesign.nyquist(5,'n',150);
%   Hd = window(h,hamming(151));
%
%   See also FDESIGN/FIRLS, FDESIGN/KAISERWIN.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/04/01 16:08:22 $

% [EOF]
