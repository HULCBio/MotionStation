function pack = wpcoef(Ts,Ds,node)
%WPCOEF Wavelet packet coefficients.
%   X = WPCOEF(S,D,N) returns the coefficients associated
%   with the node N. S is the tree structure and D
%   the data structure (see MAKETREE).
%   If N doesn't exist, X = [];
%
%   X = WPCOEF(S,D) is equivalent to X = WPCOEF(S,D,0) 
%
%   See also MAKETREE, WPDEC, WPDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 04-May-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.11 $

% Check arguments.
if errargn(mfilename,nargin,[2 3],nargout,[0 1]), error('*'); end
if nargin==2, node = 0; end

[nul,nul,pack] = wpjoin(Ts,Ds,node);
