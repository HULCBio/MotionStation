% TUKEYWIN Tukey �E�B���h�E
% W = TUKEYWIN(N,R) �́A��x�N�g���ŁAN-�_Tukey�E�B���h�E��Ԃ��܂��B
% Tukey�E�B���h�E�́A�܂��A�]��-�e�[�p�E�B���h�E�Ƃ��Ă��m����
% ���܂��B R�p�����[�^�́A����Ԃɂ�����e�[�p�̔䗦���w�肵�܂��B
% ���̔�́A1 (���Ȃ킿�A0 < R < 1)�ɋK�i������Ă��܂��B
% R�̒l���ɒ[�ȏꍇ�ATukey �E�B���h�E�́A���̋��ʂ̃E�B���h�E��
% �މ����邱�ƂɁA���ӂ��Ă��������B
% �]���āAR = 1�̏ꍇ�A����́AHanning �E�B���h�E�Ɠ����ł��B�t�ɁA
% R = 0�ɑ΂��āATukey �E�B���h�E�́A�萔�l(���Ȃ킿�Aboxcar)
% �����肵�܂��B
%
% ���:
%         N = 64; 
%         w = tukeywin(N,0.5); 
%         plot(w); title('64-point Tukey window, Ratio = 0.5');
%
% �Q�l    BARTLETT, BARTHANNWIN, BLACKMAN, BLACKMANHARRIS, 
%         BOHMANWIN, CHEBWIN, GAUSSWIN, HAMMING, HANN, KAISER,
%         NUTTALLWIN, RECTWIN, TRIANG, WINDOW.
%
% �Q�l����:
%     [1] fredric j. harris [sic], On the Use of Windows for Harmonic Analysis
%         with the Discrete Fourier Transform, Proceedings of the IEEE,
%         Vol. 66, No. 1, January 1978, Page 67, Equation 38.


%   Copyright 1988-2002 The MathWorks, Inc.
