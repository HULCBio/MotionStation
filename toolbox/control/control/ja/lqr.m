% LQR   �A�����ԃV�X�e���ɑ΂�����`2�����M�����[�^��݌v
%
%
% [K,S,E] = LQR(A,B,Q,R,N) �́A���̕]���֐�
%
%   J = Integral {x'Qx + u'Ru + 2*x'Nu} dt
%                        .
% ���A��ԃ_�C�i�~�b�N�X x = Ax + Bu �ŁA�ŏ��ɂ����ԃt�B�[�h�o�b�N�� 
% u = -Kx �̍œK�Q�C���s�� K ���v�Z���܂��B
%
% �s�� N �́A�ȗ�����ƃ[���ɐݒ肵�܂��B
% �܂��ARiccati �������̉� S �ƕ��[�v�̌ŗL�l E �����߂܂��B
%                    -1
%   SA + A'S - (SB+N)R  (B'S+N') + Q = 0 ,    E = EIG(A-B*K) 
%
%
% �Q�l : LQRY, DLQR, LQGREG, CARE, REG.


% Copyright 1986-2002 The MathWorks, Inc.
