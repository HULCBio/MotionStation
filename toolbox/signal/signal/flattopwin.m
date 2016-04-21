function w = flattopwin(varargin)
%FLATTOPWIN Flat Top window.
%   FLATTOPWIN(N) returns the N-point symmetric Flat Top window in a column 
%   vector.
%   FLATTOPWIN(N,SFLAG) generates the N-point Flat Top window using SFLAG
%   window sampling. SFLAG may be either 'symmetric' or 'periodic'. By 
%   default, a symmetric window is returned. 
%
%   EXAMPLE:
%      w = flattopwin(64); 
%      wvtool(w);
%
%   See also BARTHANNWIN, BARTLETT, BLACKMANHARRIS, BOHMANWIN,
%            NUTTALLWIN, PARZENWIN, RECTWIN, TRIANG, WINDOW.

%   Reference:
%     [1] Bruel & Kjaer, Windows to FFT Analysis (Part I), Technical
%     Review, No. 3, 1987

%   Author(s): V. Pellissier, P. Costa
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/11/21 15:46:41 $

error(nargchk(1,2,nargin));

[w,msg] = gencoswin('flattopwin',varargin{:});
error(msg);

% [EOF]
