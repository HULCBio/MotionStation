% C2D   �A���n���痣�U�n�ւ̕ϊ�
%
% SYSD = C2D(SYSC,TS,METHOD) �́A�A�����Ԃ�LTI���f�� SYSC ���A�T���v��
% ���� TS �ŁA���U���ԃ��f�� SYSD �ɕϊ����܂��B������ METHOD �́A����
% �����痣�U����@��I�����܂��B
%
%   'zoh'       ���͂�0���z�[���h��K�p
%   'foh'       ���͂ɐ��`���(�O�p�ߎ�)��K�p
%   'imp'       �C���p���X�s�ϗ��U��
%   'tustin'    �o1��(Tustin)�ߎ�
%   'prewarp'   �ϊ��O�ƕϊ���ŁA�ݒ肵��(�ՊE)���g���ŁA��������v����
%               ����̂��ƂŁATustin �ߎ����s���܂��B�ՊE���g��Wc(rad/s)
%               �́ASYSD = C2D(SYSC,TS,'prewarp',Wc) �Őݒ肷��悤�ɁA
%               4�Ԗڂ̓��͈����Ƃ��Đݒ肵�܂��B
%   'matched'   Matched pole-zero �@(SISO�V�X�e���̂�)
% 
% METHOD ���ȗ������ƁA�f�t�H���g�̎�@ 'zoh' ���p�����܂��B
%
% ��ԋ�ԃ��f�� SYS �ɑ΂��āA
% 
%   [SYSD,G] = C2D(SYSC,TS,METHOD)
% 
% �́A�A���n�̏��������𗣎U�n�̏��������ɕϊ�����s�� G ���o�͂��܂��B 
% ���ɁAx0�Au0 �� SYSC �ɑ΂��鏉����ԂƏ������͂Ƃ���Ƃ��ASYSD �ɑ΂���
% �����ȏ���������
% 
%   xd0 = G * [x0;u0],     ud0 = u0 
% 
% �ƂȂ�܂��B
%
% �Q�l : D2C, D2D, LTIMODELS/


%	Clay M. Thompson  7-19-90, A. Potvin 12-5-95
%       P. Gahinet  7-18-96
%	Copyright 1986-2002 The MathWorks, Inc. 
