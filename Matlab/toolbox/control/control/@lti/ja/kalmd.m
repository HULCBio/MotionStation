% KALMD   �A�����Ԃ̃v�����g�ɑ΂��闣�U���Ԃ�Kalman��Ԑ������쐬
%
%
% [KEST,L,P,M,Z] = KALMD(SYS,Qn,Rn,Ts) �́A�A�����Ԃ̃v�����g�ɑ΂��A 
%      .
%      x = Ax + Bu + Gw      {��ԕ�����}
%      y = Cx + Du +  v      {�ϑ�������}
%
% �U���Ԃ�Kalman��Ԑ���� KEST ���쐬���܂��B
%
% �v���Z�X�m�C�Y�Ɗϑ��m�C�Y�́A���̂悤�ɂȂ�܂��B
%
%   E{w} = E{v} = 0,  E{ww'} = Qn,  E{vv'} = Rn,  E{wv'} = 0
%
% LTI �V�X�e�� SYS �́A�v�����g�f�[�^ (A,[B G],C,[D 0]) ��ݒ肵�܂��B
% �A�����Ԃ̃v�����g�Ƌ����U�s�� (Q,R) �́A���߂ɁA�T���v������ Ts �ƃ[�����z�[
% ���h�ɂ��ߎ���p���ė��U������A���̌��ʂ̗��U���Ԃ̃v�����g�ɑ΂��闣�U
% ���Ԃ�Kalman��Ԑ������AKALMAN �ɂ���Čv�Z���܂��B
%
% �����̃Q�C�� L �ƃC�m�x�[�V�����̃Q�C�� M �ƒ��΍��̋����U�s�� P��
% Z ���o�͂��܂�(�ڍׂ́AHELP DKALMAN �ƃ^�C�v���Ă�������)�B
%
% �Q�l : LQRD, KALMAN, LQGREG.


% Copyright 1986-2002 The MathWorks, Inc.
