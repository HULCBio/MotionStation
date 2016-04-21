function x = wprcoef(t,node)
%WPRCOEF Reconstruct wavelet packet coefficients.
%   X = WPRCOEF(T,N) computes reconstructed coefficients
%   of the node N of the wavelet packet tree T.
%
%   X = WPRCOEF(T) is equivalent to X = WPRCOEF(T,0).
%
%   See also WPDEC, WPDEC2, WPREC, WPREC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/03/15 22:39:22 $

% Check arguments.
if nargin==1, node = 0; end
if find(isnode(t,node)==0)
    error('Invalid node value.');
end
x = rnodcoef(t,node);