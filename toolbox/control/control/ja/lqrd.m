% LQRD   �A�����ԕ]���֐����痣�U���Ԑ��`2���`�����M�����[�^��݌v
%
%
% [K,S,E] = LQRD(A,B,Q,R,Ts) �́A���̘A�����ԕ]���֐��Ɠ����ȗ��U���ԕ]��
% �֐����ŏ������闣�U���ԏ�ԃt�B�[�h�o�b�N�� u[n] = -K x[n] �̍œK�Q�C��
% �s�� K �����߂܂��B
% ����́A���U�����ꂽ��ԃ_�C�i�~�N�X x[n+1] = Ad x[n] + Bd u[n] ��
%
%   J = Integral {x'Qx + u'Ru} dt
%
% �����ŁA[Ad,Bd] = C2D(A,B,Ts) �ł��B
% ���U Riccati �������̉� S �ƕ��[�v�̌ŗL�l E = EIG(Ad-Bd*K) ���o�͂��܂��B
%
% [K,S,E] = LQRD(A,B,Q,R,N,Ts) �́A���̂���ʓI�ȕ]���֐��������܂��B
%   J = Integral {x'Qx + u'Ru + 2*x'Nu} dt
%
% �A���S���Y��:  �A�����ԃv�����g(A, B, C, D)�ƘA�����Ԃ̏d�ݍs��(Q, R, N)�́A
% �T���v������ Ts �[�����z�[���h�ɂ��ߎ���p���ė��U������܂��B
% �Q�C���s�� K�́A���̂Ƃ� DLQR ��p���Čv�Z����܂��B
%
% �Q�l : DLQR, LQR, C2D, KALMD.


% Copyright 1986-2002 The MathWorks, Inc.
