% ESTIM   �����Q�C����^���āA�������쐬
%
% EST = ESTIM(SYS,L) �́A��ԋ�ԃ��f�� SYS �̂��ׂĂ̓��͂͊m���I�ŁA
% ���ׂĂ̓��͂��ϑ������Ƃ�������̊�ɁA���f�� SYS �̏o�͂Ə�Ԃ�
% ���āA�Q�C�� L ��������� EST �����߂܂��B�A���n�ł́A 
%          .
%   SYS:   x = Ax + Bw ,   y = Cx + Dw   (�� �͊m���I)
% 
% ���ʂ̐����́A
%     .
%    x_e  = [A-LC] x_e + Ly
%
%   |y_e| = |C| x_e 
%   |x_e|   |I|
%
% �ŁAx �� y �̐���l x_e �� y_e �����߂܂��BESTIM �́A���U���ԃV�X�e��
% �ɓK�p���ꂽ�Ƃ��A�����悤�ɓ����܂��B
%
% EST = ESTIM(SYS,L,SENSORS,KNOWN) �́A�m��I�ȓ��͂Ɗm���I�ȓ��̗͂���
% �Ƒ���\�ȏo�͂Ƒ���ł��Ȃ��o�̗͂��������A����ʓI�ȃv�����g 
% SYS �������܂��B�C���f�b�N�X�x�N�g�� SENSORS �� KNOWN �́A�ǂ̏o�� y 
% ������\�ŁA�ǂ̓��� u �����m�ł��邩�������܂��B���ʂ̐���� EST �́A
% ����l [y_e;x_e] �����߂邽�߂̓��͂Ƃ��āA[u;y] �𗘗p���܂��B  
%
% �����(�I�u�U�[�o)�Q�C�� L �����߂�ɂ́A�ɔz�u(PLACE �Q��)�̎�@��
% �p���邱�Ƃ��ł��܂��B�܂��AKALMAN �܂��� KALMD �ɂ���ċ��߂��� 
% Kalman�t�B���^�Q�C���𗘗p���邱�Ƃ��ł��܂��B 
%
% �Q�l : PLACE, KALMAN, KALMD, REG, LQGREG, SS.


%   Clay M. Thompson 7-2-90
%   Revised: P. Gahinet 7-30-96
%   Copyright 1986-2002 The MathWorks, Inc. 
