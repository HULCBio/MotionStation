function w = nuttallwin(N)
%NUTTALLWIN Nuttall の定義の最小4-項 Blackman-Harris ウィンドウ
%   を定義します｡
%   NUTTALLWIN(N) は、Albert H. Nuttalの論文に従う係数をもつ
%   N-点修正最小4-項 Blackman-Harris ウィンドウを返します。
%
%   例題:
%      N = 32; 
%      w = nuttallwin(N); 
%      plot(w); title('32-point Nuttall window');
%
%   参考:    BARTLETT, BARTHANNWIN, BLACKMAN, BLACKMANHARRIS,  
%            BOHMANWIN,CHEBWIN, GAUSSWIN, HAMMING, HANN, KAISER, 
%            RECTWIN, TRIANG, TUKEYWIN, WINDOW.

%   Reference:
%     [1] Albert H. Nuttall, Some Windows with Very Good Sidelobe
%         Behavior, IEEE Transactions on Acoustics, Speech, and 
%         Signal Processing, Vol. ASSP-29, No.1, February 1981

%   Author(s): P. Costa

error(nargchk(1,1,nargin));

% Check for valid window length (i.e., N < 0)
[N,w,trivialwin] = check_order(N);
if trivialwin, return, end;

% Coefficients obtained from page 89 of [1]
a = [0.3635819 0.4891775 0.1365995 0.0106411];
w = min4termwin(N,a);

% [EOF]


%   Copyright 1988-2002 The MathWorks, Inc.
