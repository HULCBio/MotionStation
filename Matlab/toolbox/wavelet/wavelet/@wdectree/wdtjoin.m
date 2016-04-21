function [t,x] = wdtjoin(t,node)
%WDTJOIN Recompose wavelet packet.
%   WDTJOIN updates the wavelet packet tree after 
%   the recomposition of a node.
%
%   T = WDTJOIN(T,N) returns the modified tree T
%   corresponding to a recomposition of the node N.
%
%   T = WDTJOIN(T) is equivalent to T = WDTJOIN(T,0).
%
%   [T,X] = WDTJOIN(T,N) also returns the coefficients
%   of the node.
%
%   [T,X] = WDTJOIN(T) is equivalent to [T,X] = WDTJOIN(T,0).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 13-Mar-2003.
%   Last Revision: 13-Mar-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/15 22:39:00 $

% Check arguments.
msg = nargoutchk(1,2,nargout); error(msg);
msg = nargchk(1,2,nargin); error(msg);
if nargin == 1, node = 0; end

% Recomposition of the node.
[t,x] = nodejoin(t,node);