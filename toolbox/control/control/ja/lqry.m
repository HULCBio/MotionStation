% LQRY   �o�͂ɏd�݂�^�������`2���`�����M�����[�^��݌v
%
%
% [K,S,E] = LQRY(SYS,Q,R,N) �́A���̂悤�ȍœK�ȃQ�C���s�� K �����߂܂��B
%
%  * SYS ���A�����ԃV�X�e���̏ꍇ�A��ԃt�B�[�h�o�b�N�� u = -Kx �́A�ΏۂƂ���
%    �V�X�e���_�C�i�~�N�X  dx/dt = Ax + Bu,  y = Cx + Du �̂��Ƃł��̃R�X�g
%    �֐����ŏ������܂��B
%
%      J = Integral {y'Qy + u'Ru + 2*y'Nu} dt
%
%  * SYS �����U���ԃV�X�e���̏ꍇ�Au[n] = -Kx[n] �́Ax[n+1] = Ax[n] + Bu[n],   
%    y[n] = Cx[n] + Du[n] �̂��Ƃł��̃R�X�g�֐����ŏ������܂��B
%
%      J = Sum {y'Qy + u'Ru + 2*y'Nu}
%
% �s�� N �́A�ȗ�����ƃ[���ɐݒ肵�܂��B
% �㐔Riccati �������̉� S �ƕ��[�v�̌ŗL�l E = EIG(A-B*K) ���o�͂���܂��B
%
% �Q�l : LQR, DLQR, LQGREG, CARE, DARE.


% Copyright 1986-2002 The MathWorks, Inc.
