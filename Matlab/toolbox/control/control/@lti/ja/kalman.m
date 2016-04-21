% KALMAN   �A���A���U��Kalman��Ԑ������쐬���܂��B
%
%
% [KEST,L,P] = KALMAN(SYS,QN,RN,NN) �́A��ԋ�ԃ��f�� SYS �ŕ\�����A���A
% �܂��́A���U�̃v�����g�ɑ΂��āA Kalman ��Ԑ���� KEST ��݌v���܂��B����
% �A�����ԃv�����g�ł́A . x = Ax + Bu + Gw            {��ԕ�����}
% y = Cx + Du + Hw + v        {�ϑ�������}
%
% ���A���m�̓��� u�A�v���Z�X�m�C�Y w�A�ϑ��m�C�Y v�A�����U�m�C�Y
%
%  E{ww'} = Qn,     E{vv'} = Rn,     E{wv'} = Nn,
%
% �������Ă���Ƃ��A����� KEST �́A���� [u;y]�������Ay, x �̍œK�Ȑ���l
%  . x_e  = Ax_e + Bu + L(y - Cx_e - Du)
%
%  |y_e| = | C | x_e + | D | u |x_e|   | I |       | 0 |
%
% ���U���Ԃ̍����������ɂ��Ă̏ڍׂ́AHELP DKALMAN �ƃ^�C�v���Ă��������B
%
% ��ԋ�ԃ��f�� SYS �́A�v�����g�f�[�^ (A,[B G],C,[D H]) �������Ă��āANN ��
% �ȗ����ꂽ�Ƃ��A�[���Ɛݒ肳��܂��BQN �̍s�̃T�C�Y�́A�m�C�Y����w (SYS �ւ�
% �ŐV����)�̐���ݒ肵�܂��BKalman ��Ԑ���� KEST �́ASYS ���A���̏ꍇ�A�A��
% �ɂȂ�A���̏ꍇ�A���U�ɂȂ�܂��B
%
% KALMAN �́A�����Q�C�� L �ƒ��΍��̋����U P ������܂��B
% H = 0 �ŁA�A�����Ԃł́AP �́A����Riccati �������������ċ��߂��܂��B -1
%                                                            AP + PA' - (PC'+G*N)R  (CP+N'*G') + G*Q*G' = 0
%
%
% [KEST,L,P] = KALMAN(SYS,QN,RN,NN,SENSORS,KNOWN) �́A���̂悤�ȁA�����
% �I�ȗ���������܂��B * SYS �̏o�͂̂����ꂩ������ł��Ȃ��B * �m�C�Y����
% w �́ASYS �ւ̍ŐV���͂łȂ��B �C���f�b�N�X�x�N�g�� SENSORS �� KNOWN �́A
% SYS �̂ǂ̏o�� y ������\���ǂ̓��͂����m���������܂��B���̂��ׂĂ̓���
% �͊m���I�ł���Ɖ��肵�܂��B
%
% �Q�l : KALMD, ESTIM, LQGREG, SS, LTIMODELS, CARE, DARE.


% Copyright 1986-2002 The MathWorks, Inc.
