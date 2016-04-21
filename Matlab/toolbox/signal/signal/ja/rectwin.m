function w = rectwin(n_est)
%RECTWIN �����`�̃E�B���h�E
%   W = RECTWIN(N) N�_�����`�E�B���h�E
%
%   �Q�l     BARTLETT, BARTHANNWIN, BLACKMAN, BLACKMANHARRIS,
%            BOHMANWIN, CHEBWIN, GAUSSWIN, HAMMING, HANN, KAISER, 
%            NUTTALLWIN, TRIANG, TUKEYWIN, WINDOW.


[n,w,trivialwin] = check_order(n_est);
if trivialwin, return, end;

w = ones(n,1);

% [EOF] 



%   Copyright 1988-2002 The MathWorks, Inc.
