function x = wprec2(wpt)
%WPREC2 Wavelet packet reconstruction 2-D.
%   X = WPREC2(T) returns the reconstructed vector
%   corresponding to a wavelet packet tree T.
%
%   See also WPDEC, WPDEC2, WPJOIN, WPREC, WPSPLT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/03/15 22:39:24 $

[wpt,x] = nodejoin(wpt);