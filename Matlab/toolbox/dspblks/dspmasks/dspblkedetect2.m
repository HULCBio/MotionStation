function varargout = dspblkedetect2()
% DSPBLKEDETECT2 Signal Processing Blockset Edge Detection block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.4.4.2 $ $Date: 2004/04/12 23:06:24 $

x = [.1 .2 .2 .5 .5 .7 .7 .8 .8 .9 NaN ...
     .1 .9 NaN .2 .2 NaN .7 .7];

y = [.6 .6 .9 .9 .6 .6 .9 .9 .6 .6 NaN ...
     .1 .1 NaN .1 .5 NaN .1 .5];

varargout = {x,y};

