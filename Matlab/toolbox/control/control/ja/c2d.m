% C2D�́A�A���n���痣�U�n�ւ̕ϊ����s���܂��B
%
%
% SYSD = C2D(SYSC,TS,METHOD) �́A�A�����Ԃ� LTI ���f�� SYSC ���A�T���v������
% TS �ŁA���U���ԃ��f�� SYSD �ɕϊ����܂��B������ METHOD �́A���̒����痣�U
% ����@��I�����܂��B'zoh'       ���͂�0���z�[���h��K�p
%    'foh'       ���͂ɐ��`���(�O�p�ߎ�)��K�p
%    'imp'       �C���p���X�s�ϗ��U��
%    'tustin'    �o1��(Tustin)�ߎ�
%    'prewarp'   �ϊ��O�ƕϊ���ŁA�ݒ肵��(�ՊE)���g���ŁA��������v���鐧���
%                ���ƂŁATustin �ߎ����s���܂��B �ՊE���g��Wc(rad/s) �́A
%                   SYSD = C2D(SYSC,TS,'prewarp',Wc) 
%                �Őݒ肷��悤�ɁA4�Ԗڂ̓��͈����Ƃ��Đݒ肵�܂��B
%    'matched'   Matched pole-zero �@(SISO �V�X�e���̂�) METHOD ���ȗ������ƁA
% �f�t�H���g�̎�@ 'zoh' ���p�����܂��B
%
% [SYSD,G] = C2D(SYSC,TS,METHOD) �́A�A���n�̏��������𗣎U�n�̏��������ɕ�
% ������s�� G ���o�͂��܂��B���ɁAx0�Au0 �� SYSC �ɑ΂��鏉����ԂƏ������͂�
% ����Ƃ��ASYSD �ɑ΂��铙���ȏ��������� 
%    xd[0] = G * [x0;u0],   ud[0] = u0 
% �ƂȂ�܂��B
%
% �Q�l : D2C, D2D, LTIMODELS


% Copyright 1986-2002 The MathWorks, Inc.
