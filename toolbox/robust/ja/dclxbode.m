% DCLXBODE   ���U���f���g������(SIMO)
%
% [G] = DCLXBODE(SS_,IU,W,TS)�A�܂��́A
% [G] = DCLXBODE(A,B,C,D,IU,W,TS) �́A�V�X�e��
% 
%			x[n+1] = Ax[n] + Bu[n]	                -1
%			y[n]   = Cx[n] + Du[n]	   G(z) = C(zI-A) B + D
%
% �̓��� iu ����̎��g���������v�Z���܂��B�x�N�g�� W �́ABode �������v�Z
% ������g���_�����W�A���ŕ\�������̂ł��BDCLBODE �́A�o�� y �Ɠ����̗�
% �������ALENGTH(W) �Ɠ����s�������s�� MAG �� PHASE(�x�P��) ���o�͂���
% ���B
%

% Copyright 1988-2002 The MathWorks, Inc. 
