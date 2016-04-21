function w = hamming(varargin)
%HAMMING   Hamming window.
%   HAMMING(N) returns the N-point symmetric Hamming window in a column vector.
% 
%   HAMMING(N,SFLAG) generates the N-point Hamming window using SFLAG window
%   sampling. SFLAG may be either 'symmetric' or 'periodic'. By default, a 
%   symmetric window is returned. 
%
%   See also BLACKMAN, HANN, WINDOW.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.14 $  $Date: 2002/11/21 15:46:43 $

% Check number of inputs
error(nargchk(1,2,nargin));

[w,msg] = gencoswin('hamming',varargin{:});
error(msg);


% [EOF] hamming.m
