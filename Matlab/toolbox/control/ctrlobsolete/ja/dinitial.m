% DINITIAL   ���U���Ԑ��`�V�X�e���̉����̏�������
%
% DINITIAL(A,B,C,D,X0) �́A���U�V�X�e��
% 
%    x[n+1] = Ax[n] + Bu[n]
%    y[n]   = Cx[n] + Du[n]
%
% �ɑ΂��āA������Ԃɂ�鉞�����v���b�g���܂��B�������v�Z����_���́A
% �V�X�e���̋ɂƗ�_���x�[�X�Ɏ����I�Ɍ��肵�܂��B
%
% DINITIAL(A,B,C,D,X0,N) �́A�������v�Z����_�� N ��ݒ肵�܂��B�܂��A
% ���ӂɏo�͈����Ɛݒ肵���ꍇ�A
%
%    [Y,X,N] = DINITIAL(A,B,C,D,X0,...)
%
% �́A�o��(Y)�Ə�Ԃ̉���(X)�A�v�Z���������̓_��(N)���o�͂��A�X�N���[����
% �Ƀv���b�g�\�����s���܂���BY �́A�o�͂���鐔�̗񐔂������AX �͏�Ԑ�
% �Ɠ������̗񐔂������Ă��܂��B
% 
% �Q�l : DIMPULSE,DSTEP,DLSIM, INITIAL.


%	Clay M. Thompson  7-6-90
%	Revised ACWG 6-21-92
%	Revised AFP 9-21-94,  PG 4-25-96
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:45 $
