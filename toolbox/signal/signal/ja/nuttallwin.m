function w = nuttallwin(N)
%NUTTALLWIN Nuttall �̒�`�̍ŏ�4-�� Blackman-Harris �E�B���h�E
%   ���`���܂��
%   NUTTALLWIN(N) �́AAlbert H. Nuttal�̘_���ɏ]���W��������
%   N-�_�C���ŏ�4-�� Blackman-Harris �E�B���h�E��Ԃ��܂��B
%
%   ���:
%      N = 32; 
%      w = nuttallwin(N); 
%      plot(w); title('32-point Nuttall window');
%
%   �Q�l:    BARTLETT, BARTHANNWIN, BLACKMAN, BLACKMANHARRIS,  
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
