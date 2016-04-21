function x = wdtrec(t,node)
%WDTREC Wavelet decomposition tree reconstruction.
%   X = WDTREC(T) returns the reconstructed vector
%   corresponding to a wavelet packet tree T.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 13-Mar-2003.
%   Last Revision: 13-Mar-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/15 22:39:01 $ 

% Check arguments.
msg = nargoutchk(0,1,nargout); error(msg);
msg = nargchk(1,1,nargin); error(msg);
if nargin==1, node = 0; end

% Get node coefficients.
[t,x] = nodejoin(t,node);
