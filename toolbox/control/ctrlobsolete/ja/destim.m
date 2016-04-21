% DESTIM   ���U Kalman �����
%
% [Ae,Be,Ce,De] = DESTIM(A,B,C,D,L) �́A���U�V�X�e�� (A,B,C,D) ���x�[�X�ɁA
% Kalman �Q�C���s�� L ���g���āAKalman �������쐬���܂��B�����ł́A
% �V�X�e���̂��ׂĂ̏o�͂̓Z���T�o�͂Ɖ��肵�Ă��܂��B���ʋ��܂��ԋ��
% �����́A���̂悤�ɕ\���܂��B
%
%    xBar[n+1] = [A-ALC] xBar[n] + [AL] y[n]
%
%     |yHat|   = |C-CLC| xBar[n] + |CL| y[n]
%     |xHat|     |I-LC |           |L |
%
% �����ŁA���͂Ƃ��ăZ���T  y ���l���A���肵���Z���T yHat �Ɛ��肵����� 
% xHat ���o�͂Ƃ��Ă��܂��B
%
% [Ae,Be,Ce,De] = DESTIM(A,B,C,D,L,SENSORS,KNOWN) �́ASENSORS �Őݒ肵��
% �Z���T�� KNOWN �Ŏw�肵���t���I�Ȋ��m���͂��g���āAKalman �������쐬
% ���܂��B���ʂ̃V�X�e���́A���͂Ƃ��āA���m�̓��͂ƃZ���T���g���āA�o��
% �Ƃ��ăZ���T�Ə�Ԃ𐄒肵�܂��BKNOWN ���͂́A�v�����g�̔�m���I�ȓ��͂ŁA
% �ʏ�A������͂Ƃ��čl���܂��B
%
% �Q�l : DLQE, DLQR, DREG, ESTIM.


%   Clay M. Thompson 7-2-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:39 $
