% LQR2   �A�����ԃV�X�e���ɑ΂�����`-�񎟃��M�����[�^
% 
% [K,S] = LQR2(A,B,Q,R) �́A���̍S��������
%       .
%       x = Ax + Bu 
% 
% �̂��ƂŁA�]���֐�
% 
%      J = Integral {x'Qx + u'Ru} dt
% 
% ���ŏ��ɂ���t�B�[�h�o�b�N�� u = -Kx �̍œK�t�B�[�h�o�b�N�Q�C���s���
% �v�Z���܂��B
%    
% �܂��A�֘A�����㐔 Riccati ������ 
%                          -1
%        0 = SA + A'S - SBR  B'S + Q
%
% �̒���Ԃ̉� S ���o�͂��܂��B[K,S] = LQR2(A,B,Q,R,N) �́A�]���֐���
% �ŁAu �� x ���֘A�t����N���X�� 2x'Nu ����荞��ł��܂��B
%
% �R���g���[���́AREG ���g���č쐬�ł��܂��B
%
% LQR2 �́A�Q�l���� [1] �� SCHUR �A���S���Y�����g���A�ŗL�l�������g�� 
% LQR3 �������l�I�ɐM����������܂��B
%
% �Q�l : ARE, LQR, LQE2.


%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:08:10 $
