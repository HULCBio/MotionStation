% IDDATA/PLOT �́A���o�̓f�[�^���v���b�g���܂��B
% 
%   PLOT(DATA)    
%
% DATA �́AIDDATA �I�u�W�F�N�g�̓��o�̓f�[�^�ł��B
% AXIS �́A�I�u�W�F�N�g���瓾���鎲���ł��B
%
% �f�[�^�̈ꕔ���v���b�g���邽�߂ɂ́A�T�u���t�@�����X������g���܂��B
%
% PLOT(DATA(201:300))�A�܂��́APLOT(DATA(201:300,Outputs,Inputs)) �́AP-
% LOT(DATA(201,'Altitude',{'Angle_of_attack','Speed'}))�A�܂��́APLOT(D-
% ATA(:,[3 4],[3:7])�Ɠ��l�ł��B
%
% ���̃X�e�[�g�����g�ŁA�����̃f�[�^���r���邱�Ƃ��ł��܂��B
% 
%   PLOT(dat1,dat2,...,datN)
% 
% �J���[�A���C���X�^�C���A�}�[�J�́APlotStyle �Őݒ�ł��܂��B
% 
%   PLOT(dat1,'PlotStyle1',dat2,'PlotStyle2',....,datN,'PlotStyleN')
% 
% PlotStyle �́A'b', 'b+:',���X�̒l���g�p�ł��܂��BHELP PLOT ���Q�Ƃ��Ă�
% �������B
%
% �M���́A���� InputNames �� OutputNames ��(�����̎����f�[�^�ɂ�)����Ex-
% perimentName�����M�����e�v���b�g���܂ނ悤�Ƀv���b�g����܂��BReturn
% �L�[���������тɁA�v���b�g�͐i�݂܂��BCTRL-C ���^�C�v���邱�ƂŁA�v���b
% �g��r���ŋ����I�����܂��B
%
% ���͂Əo�͂̃f�[�^�Z�b�g�ɑ΂��āA�v���b�g�́A����/�o�͂̂��ꂼ��̑g��
% �ʁX�ɂȂ�悤�ɕ������܂��B���͂܂��͏o�͂̂ǂ��炩���܂�ł��Ȃ��f�[
% �^�Z�b�g�ɑ΂��āA�M���͕ʁX�ɕ\������܂��B
%
% ���͐M���́A�v���p�e�B'InterSample' (foh ���邢�� zoh)�Ƃ��āA���`�ɓ��}
% ���ăv���b�g���ꂽ�Ȑ��A���邢�́A�K�i��̃v���b�g�Ƃ��ăv���b�g����܂��B

%   L. Ljung 87-7-8, 93-9-25


%   Copyright 1986-2001 The MathWorks, Inc.