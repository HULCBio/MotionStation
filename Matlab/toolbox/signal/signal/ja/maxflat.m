% MAXFLAT �́A�ł�����蕽�R�Ȕėp�f�B�W�^��Butterworth�t�B���^��݌v��
% �܂��B
%
% [B,A] = MAXFLAT(NB,NA,Wn)�́A���ꂼ��A����NB�����NA�̕��q�W��B�����
% ����W��A�������[�p�XButterworth�t�B���^��݌v���܂��BWn�̓J�b�g�I�t
% ���g���ŁA���̎��g���ŁA�t�B���^�̃Q�C�������� 1/sqrt(2)(�� -3dB)�Ƃ�
% ��܂��BWn��0��1�̊ԂŁA1�̓t�B���^�̃T���v�����O���g����1/2�ł��BNA��
% 0�̏ꍇ�A�t�B���^�̎��g�������𕽊������邽�߂ɁAWn�͈̔͂́A���Ȃ萧
% ������܂��B
%
% B = MAXFLAT(NB,'sym',Wn)�́A�Ώ�FIR Butterworth�t�B���^��݌v���܂��B
% NB�͋����ŁAWn��[0,1]�ɐ�������܂��BWn���A���̋�Ԃ̊O�ɐݒ肳�ꂽ��
% ���A�֐��̓G���[�ɂȂ�܂��B
%
% [B,A,B1,B2] = MAXFLAT(NB,NA,Wn) �� [B,A,B1,B2] = MAXFLAT(NB,'sym',Wn) 
% �́A���q������B�𑽍��� B1 �� B2 �̐�(B = CONV(B1,B2))�ɂȂ�悤�ɕ���
% �������������o�͂��܂��BB1 �� z = -1 �ł̂��ׂĂ̗�_���܂݁AB2 �͑���
% ��_���܂݂܂��B
%
% ��� 1: IIR �݌v
%      NB = 10; NA = 2; Wn = 0.6;
%      [b,a,b1,b2] = maxflat(NB,NA,Wn);
%      fvtool(b,a);
% ��� 2: FIR �݌v
%      NB = 10; Wn = 0.6;
%      h = maxflat(NB,'sym',Wn); 
%      fvtool(h);
%
% �݌v�̃��j�^�����O
% �݌v�Ŏg�p����Ă���݌v�e�[�u���̃e�L�X�g�\���p�ɁA���Ƃ��΁AMAXFLAT
% (NB,NA,Wn,'trace') �̂悤�ɁA�Ō�� 'trace' ������t���Ďg�p���܂��B�t
% �B���^�̑傫���A�x���A��_�A�ɂ��v���b�g�\�����邽�߁A'plot' �����ŁA
% MAXFLAT(NB,NA,Wn,'plot') ���g���܂��B�e�L�X�g�\���ƃv���b�g�\��������
% �g�������ꍇ�A'both' ��ݒ肵�Ă��������B
%
% �Q�l�F   BUTTER, FREQZ, FILTER.



%   Author: Ivan Selesnick, Rice University, September 1995.
%   Copyright 1988-2002 The MathWorks, Inc.
