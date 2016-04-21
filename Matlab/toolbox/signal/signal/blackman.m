function w = blackman(varargin)
%BLACKMAN   Blackman window.
%   BLACKMAN(N) returns the N-point symmetric Blackman window in a column
%   vector.
%   BLACKMAN(N,SFLAG) generates the N-point Blackman window using SFLAG
%   window sampling. SFLAG may be either 'symmetric' or 'periodic'. By 
%   default, a symmetric window is returned. 
%
%   See also  HAMMING, HANN, WINDOW.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.14 $  $Date: 2002/11/21 15:46:42 $

% Check number of inputs
error(nargchk(1,2,nargin));

[w,msg] = gencoswin('blackman',varargin{:});
error(msg);

% [EOF] blackman.m
