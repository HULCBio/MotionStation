function h = barthannwin(varargin)
%BARTHANNWIN Modified Bartlett-Hanning window. 
%   H = SIGWIN.BARTHANNWIN(N) returns an N-point Modified Bartlett-Hanning
%   window object H.
%
%   EXAMPLE:
%      N = 64; 
%      h = sigwin.barthannwin(N);
%      w = generate(h);
%      stem(w); title('64-point Modified Bartlett-Hanning window');
%
%   See also SIGWIN/BARTLETT, SIGWIN/BLACKMANHARRIS, SIGWIN/BOHMANWIN,
%            SIGWIN/FLATTOPWIN, SIGWIN/NUTTALLWIN, SIGWIN/PARZENWIN, 
%            SIGWIN/RECTWIN, SIGWIN/TRIANG.

%   Reference:
%     [1] Yeong Ho Ha and John A. Pearce, A New Window and Comparison
%         to Standard Windows, IEEE Transactions on Acoustics, Speech,
%         and Signal Processing, Vol. 37, No. 2, February 1999

%   Author(s): P. Costa and T. Bryan
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/10/30 21:07:22 $

h = sigwin.barthannwin(varargin{:});

% [EOF]
