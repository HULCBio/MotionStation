% LQR   ��ԋ�ԃV�X�e���ɑ΂�����`2���`�����M�����[�^��݌v
%  
% [K,S,E] = LQR(SYS,Q,R,N) �́A���̂悤�ȍœK�ȃQ�C���s�� K ������
% �܂��B
%  
%   * ��ԋ�ԃ��f�� SYS ���A�����Ԃ̏ꍇ�A��ԃt�B�[�h�o�b�N�� u = -Kx 
%     �́A�ΏۂƂ���V�X�e���_�C�i�~�N�X x = Ax + Bu �̂��ƂŁA����
%     �]���֐����ŏ������܂��B
%  
%           J = Integral {x'Qx + u'Ru + 2*x'Nu} dt
%  
%   * ���U���ԏ�ԋ�ԃ��f�� SYS �ɑ΂��� u[n] = -Kx[n] �́A�ΏۂƂ���
%     �V�X�e���_�C�i�~�N�X x[n+1] = Ax[n] + Bu[n] �̂��ƂŁA���̕]��
%     �֐����ŏ������܂��B
%  
%               J = Sum {x'Qx + u'Ru + 2*x'Nu}
%  
% �s�� N �́A�ȗ�����ƃ[���ɐݒ肵�܂��B�㐔Riccati�������̉� S 
% �ƕ��[�v�̌ŗL�l E = EIG(A-B*K) ���o�͂���܂��B
%
% [K,S,E] = LQR(A,B,Q,R,N) �́A�A�����ԃ��f���ɑΉ�����\���ł��B
% �����ŁAA�AB�́A���f�� dx/dt = Ax + Bu ���w�肵�܂��B
%  
% �Q�l : LQRY, LQGREG, DLQR, CARE, DARE.


%   Author(s): J.N. Little 4-21-85
%   Revised    P. Gahinet  7-24-96
%   Copyright 1986-2002 The MathWorks, Inc. 
