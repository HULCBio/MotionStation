% DLQR   ���U���ԃV�X�e���p�̐��`2�����M�����[�^���쐬
%
%
% [K,S,E] = DLQR(A,B,Q,R,N) �́A���̕]���֐�
%
%  J = Sum {x'Qx + u'Ru + 2*x'Nu}
%
% ����ԃ_�C�i�~�b�N�X x[n+1] = Ax[n] + Bu[n] �̊�ŁA�ŏ��ɂ����ԃt�B�[�h
% �o�b�N�� u[n] = -Kx[n] �̍œK�Q�C���s�� K ���v�Z���܂��B
%
% �s�� N �́A�ȗ�����ƃ[���ɐݒ肵�܂��B
% �܂��ARiccati �������̉� S �ƕ��[�v�̌ŗL�l E �����߂܂��B
%                                -1
%     A'SA - S - (A'SB+N)(R+B'SB) (B'SA+N') + Q = 0,   E = EIG(A-B*K)
%
%
% �Q�l : DLQRY, LQRD, LQGREG, DARE.


% Copyright 1986-2002 The MathWorks, Inc.
