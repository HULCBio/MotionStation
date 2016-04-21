% SERIES   2��LTI���f����A���I�Ɍ���
%
%                               +------+
%                        v2 --->|      |
%               +------+        | SYS2 |-----> y2
%               |      |------->|      |
%      u1 ----->|      |y1   u2 +------+
%               | SYS1 |
%               |      |---> z1
%               +------+
%
% SYS = SERIES(SYS1,SYS2,OUTPUTS1,INPUTS2) �́AOUTPUTS1 �Ŏw�肳�ꂽ 
% SYS1 �̏o�͂� INPUT2 �Ŏw�肳�ꂽ SYS2 �̓��͂ɐڑ����āA2��LTI���f��
% SYS1 �� SYS2 ��ڑ����܂��B�x�N�g�� OUTPUTS1 �� INPUTS2 �́ASYS1 ��
% SYS2 �̏o�͂Ɠ��͂̊֌W�̃C���f�b�N�X���܂݂܂��B���ʂ�LTI���f�� SYS 
% �� u1 ���� y2 �֊��蓖�Ă��܂��B
%
% OUTPUTS1 �� INPUTS2 ���ȗ����ꂽ�ꍇ�ASERIES �� SYS1 �� SYS2 ���c��
% �ڑ����A���̂悤�ȏo�͂ɂȂ�܂��B
% 
%    SYS = SYS2 * SYS1
%
% SYS1 �� SYS2 �� LTI���f���̔z��̏ꍇ�ASERIES �͓����T�C�Y��LTI�z��
% SYS ���o�͂��A���̂悤�ɂȂ�܂��B 
%
%    SYS(:,:,k) = SERIES(SYS1(:,:,k),SYS2(:,:,k),OUTPUTS1,INPUTS2) 
%
% �Q�l : APPEND, PARALLEL, FEEDBACK, LTIMODELS.


%	Clay M. Thompson 6-29-90, Pascal Gahinet, 4-12-96
%	Copyright 1986-2002 The MathWorks, Inc. 
