function x = wprec2(Ts,Ds)
%WPREC2 Wavelet packet reconstruction 2-D.
%   X = WPREC2(T,D) returns the reconstructed matrix
%   X corresponding to a wavelet packet decomposition
%   structure [T,D] (see MAKETREE).
%
%   T is the tree structure and D the data structure. 
%
%   See also MAKETREE, WPDEC, WPDEC2, WPJOIN, WPREC, WPREC2,
%        WPSPLT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 04-May-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.11 $

% Check arguments.
if errargn(mfilename,nargin,[2],nargout,[0 1]), error('*'); end

[Ts,Ds,x] = wpjoin(Ts,Ds);
