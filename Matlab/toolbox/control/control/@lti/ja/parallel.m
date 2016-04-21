% PARALLEL   2��LTI�V�X�e���̕��񌋍�
%
%                       +------+
%         v1 ---------->|      |----------> z1
%                       | SYS1 |
%                u1 +-->|      |---+ y1
%                   |   +------+   |
%          u ------>+              O------> y
%                   |   +------+   |
%                u2 +-->|      |---+ y2
%                       | SYS2 |
%         v2 ---------->|      |----------> z2
%                       +------+
%
% SYS = PARALLEL(SYS1,SYS2,IN1,IN2,OUT1,OUT2) �́AIN1 ��IN2 �Ŏw�肳�ꂽ
% ���͂�ڑ����AOUT1 �� OUT2 �Ŏw�肳�ꂽ�o�͂𑫂����킹�āA2��LTI
% �V�X�e�� SYS1 �� SYS2 �����Ɍ������܂��B���ʂ�LTI���f�� SYS �́A
% [v1;u;v2] ���� [z1;y;z2] �Ɋ��蓖�Ă��܂��B�x�N�g�� IN1 �� IN2 �́A
% SYS1 �� SYS2 �ւ̓��̓x�N�g���̃C���f�b�N�X���܂�ł��āA�_�C�A�O����
% �̒��̓��̓`�����l�� u1 �� u2 ���`���Ă��܂��B���l�ɁA�x�N�g�� OUT1 
% �� OUT2 �́A�����2�̃V�X�e���̏o�͂̃C���f�b�N�X���܂�ł��܂��B
%
% IN1, IN2, OUT1, OUT2 ���A���ɏȗ����ꂽ�ꍇ�APARALLEL �́A��ʓI�� 
% SYS1 �� SYS2�̕��񌋍����`�����A���̏o�͂����܂��B
% 
%       SYS = SYS2 + SYS1 
%
% SYS1 �� SYS2 ���ALTI���f���̔z��̏ꍇ�APARALLEL �͓����T�C�Y�� LTI�z��
% SYS ���o�͂��܂��B�����ŁA
% 
%   SYS(:,:,k) = PARALLEL(SYS1(:,:,k),SYS2(:,:,k),IN1,...)
%
% �Q�l : APPEND, SERIES, FEEDBACK, LTIMODELS.


%	Clay M. Thompson 6-27-90, Pascal Gahinet, 4-15-96
%	Copyright 1986-2002 The MathWorks, Inc. 
