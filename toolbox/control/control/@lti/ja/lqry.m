% LQRY   �o�͂ɏd�݂�^�������`2���`�����M�����[�^��݌v
%
% [K,S,E] = LQRY(SYS,Q,R,N) �́A���̂悤�ȍœK�ȃQ�C���s�� K ������
% �܂��B 
%
%  * SYS ���A�����ԃV�X�e���̏ꍇ�A��ԃt�B�[�h�o�b�N�� u = -Kx �́A�Ώ�
%    �Ƃ���V�X�e���_�C�i�~�N�X  dx/dt = Ax + Bu,  y = Cx + Du �̂��Ƃ�
%    ���̃R�X�g�֐����ŏ������܂��B
%
%          J = Integral {y'Qy + u'Ru + 2*y'Nu} dt
%
%  * SYS �����U���ԃV�X�e���̏ꍇ�Au[n] = -Kx[n] �́A�ΏۂƂ���V�X�e��
%    �_�C�i�~�b�N�X x[n+1] = Ax[n] + Bu[n],   y[n] = Cx[n] + Du[n] �̂�
%    �ƂŁA���̃R�X�g�֐����ŏ������܂��B
% 
%          J = Sum {y'Qy + u'Ru + 2*y'Nu}
%                
% �s�� N �́A�ȗ�����ƃ[���ɐݒ肵�܂��B�㐔Riccati�������̉� S ��
% ���[�v�̌ŗL�l E = EIG(A-B*K) ���o�͂���܂��B
%
% �Q�l : LQR, DLQR, LQGREG, CARE, DARE.


%   J.N. Little 7-11-88
%   Revised: 7-18-90 Clay M. Thompson, P. Gahinet 7-24-96
%   Copyright 1986-2002 The MathWorks, Inc. 
