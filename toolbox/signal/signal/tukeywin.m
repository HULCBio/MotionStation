function w = tukeywin(n,r)
%TUKEYWIN Tukey window.
%   TUKEYWIN(N) returns an N-point Tukey window in a column vector.
% 
%   W = TUKEYWIN(N,R) returns an N-point Tukey window in a column vector.
%   A Tukey window is also known as the cosine-tapered window.  The R 
%   parameter specifies the ratio of taper to constant sections. This ratio 
%   is normalized to 1 (i.e., 0 < R < 1). If ommited, R is set to 0.500.
%   
%   NOTE: At extreme values of R, the Tukey window degenerates into other
%   common windows. Thus when R = 1, it is equivalent to a Hanning window.
%   Conversely, for R = 0 the Tukey window is equivalent to a boxcar window.
%
%   EXAMPLE:
%      N = 64; 
%      w = tukeywin(N,0.5); 
%      plot(w); title('64-point Tukey window, Ratio = 0.5');
%
%   See also CHEBWIN, GAUSSWIN, KAISER, WINDOW.

%   Reference:
%     [1] fredric j. harris [sic], On the Use of Windows for Harmonic Analysis
%         with the Discrete Fourier Transform, Proceedings of the IEEE,
%         Vol. 66, No. 1, January 1978, Page 67, Equation 38.

%   Author(s): A. Dowd
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2002/11/21 15:46:50 $

error(nargchk(1,2,nargin));

% Default value for R parameter.
if nargin < 2 || isempty(r), 
    r = 0.500;
end

[n,w,trivialwin] = check_order(n);
if trivialwin, return, end;

if r <= 0,
    w = ones(n,1);
elseif r >= 1,
    w = hann(n);
else
    t = linspace(0,1,n)';
    % Defines period of the taper as 1/2 period of a sine wave.
    per = r/2; 
    tl = floor(per*(n-1))+1;
    th = n-tl+1;
    % Window is defined in three sections: taper, constant, taper
    w = [ ((1+cos(pi/per*(t(1:tl) - per)))/2);  ones(th-tl-1,1); ((1+cos(pi/per*(t(th:end) - 1 + per)))/2)];
end


% [EOF]
