% INITIAL   ��ԋ�ԃ��f���̏����l�������v�Z
%
%
% INITIAL(SYS,X0) �́A������� X0 ������ԋ�ԃV�X�e��(SS�ō쐬���ꂽ)
% SYS �̎��R�������v���b�g���܂��B���̉����́A���̕������ɂ���ė^�����܂��B 
%             .
%   �A���n:   x = A x ,  y = C x ,  x(0) = x0
%
%   ���U�n:  x[k+1] = A x[k],  y[k] = C x[k],  x[0] = x0
%
% ���Ԕ͈͂Ɖ������v�Z����_���́A�����I�ɑI������܂��B
%
% INITIAL(SYS,X0,TFINAL) �́At = 0 ����ŏI���� t = TFINAL �܂ł̎��ԉ�����
% �V�~�����[�V�������܂��B�T���v�����Ԃ�ݒ肵�Ă��Ȃ����U���ԃV�X�e����
% �΂��āATFINAL ���T���v�����ɂȂ�܂��B
%
% INITIAL(SYS,X0,T) �́A�V�~�����[�V�����ŗ��p���鎞�ԃx�N�g�� T ��ݒ肵�܂��B
% ���U�n�ɑ΂��āAT �� 0:Ts:Tf �̌`���ŗ^�����A�����ŁATs �̓V�X�e����
% �T���v�����ԂɂȂ�܂��B�A���n�ɑ΂��āAT �� 0:dt:Tf �̌`���ŗ^�����A
% �����ŁAdt �͘A���n�ɑ΂��闣�U�ߎ��̃T���v�����ԂɂȂ�܂��B
%
% INITIAL(SYS1,SYS2,...,X0,T) �́A������ LTI �V�X�e�� SYS1,SYS2,... �̉�����
% 1�̃v���b�g�ɕ\�����܂��B���ԃx�N�g�� T �̓I�v�V�����ł��B
%   initial(sys1,'r',sys2,'y--',sys3,'gx',x0) 
% �̂悤�ɁA�e�V�X�e�����ɁA�J���[�A���C���X�^�C���A�}�[�J���w�肷�邱�Ƃ��ł��܂��B 
%
% ���ӂɏo�͈�����ݒ肵��
%
%   [Y,T,X] = INITIAL(SYS,X0,...) 
%
% �́A�o�͉��� Y �ƃV�~�����[�V�����ɗ��p������
% �ԃx�N�g�� T �Ə�Ԃ̋O��X ���o�͂��܂��B��ʂɂ̓v���b�g�͕\������܂���B
% �s�� Y �́ALENGTH(T) �s�� SYS �̏o�͂Ɠ����񐔂������܂��B
% ���l�ɁAX ��LENGTH(T) �̍s�������A��ԂƓ����񐔂ɂȂ�܂��B
%
% �Q�l : IMPULSE, STEP, LSIM, LTIVIEW, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
