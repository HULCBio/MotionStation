% SAVE_SYSTEM   Simulink�V�X�e���̕ۑ�
%
% SAVE_SYSTEM �́A�J�����g�̍ŏ�ʃV�X�e�������̃J�����g�̖��O�̃t�@�C���ɕ�
% �����܂��B
%
% SAVE_SYSTEM('SYS') �́A�w�肵���ŏ�ʃV�X�e�������̃J�����g�̖��O�̃t�@�C
% ���ɕۑ����܂��B�V�X�e���́A���ɊJ����Ă��Ȃ���΂Ȃ�܂���B
%
% SAVE_SYSTEM('SYS','NEWNAME') �́A�w�肵���ŏ�ʃV�X�e�����w�肵���V������
% �O�̃t�@�C���ɕۑ����܂��B�V�X�e���́A���ɊJ����Ă��Ȃ���΂Ȃ�܂���B
%
% SAVE_SYSTEM('SYS','NEWNAME','BreakLinks') �́A�w�肵���ŏ�ʃV�X�e�����w��
% �����V�������O�̃t�@�C���ɕۑ����܂��B�S�Ẵu���b�N���C�u���������N�́A�V
% �����t�@�C���ł͉�������܂��B�V�X�e���́A���ɊJ����Ă��Ȃ���΂Ȃ�܂���B
%
% SAVE_SYSTEM('SYS','NEWNAME','LINKACTION', 'VERSION') �́A�w�肵���ŏ�ʃV
% �X�e�����w�肵��NEWNAME�Ƃ������O�̋��o�[�W�����ɕۑ����܂��BLINKACTION�́A
% '' ��'BreakLinks'�̂����ꂩ�ł��BVERSION�́A'R13SP1', 'R13', 'R12P1', '
% R12'�̂����ꂩ�ł��B
%
% ���:
%
% save_system
%
% �́A�J�����g�̃V�X�e����ۑ����܂��B
%
% save_system('vdp')
%
% �́Avdp�V�X�e����ۑ����܂��B
%
% save_system('vdp','myvdp')
%
% �́Avdp�V�X�e����'myvdp'�Ƃ������O�̃t�@�C���ɕۑ����܂��B
%
% save_system('vdp','myvdp','BreakLinks')
%
% �́Avdp�V�X�e����'myvdp'�Ƃ������O�̃t�@�C���ɕۑ����A�u���b�N���C�u��
% ���̃����N���������܂��B
%
% save_system('vdp', 'myvdp', '', 'R13SP1')
%
% �́A'vdp'�V�X�e����'myvdp'�Ƃ������O��Simulink��R13(SP1)�o�[�W�����ɕۑ���
% �܂��B�u���b�N���C�u�����ւ̃����N�͉������܂���B
%
% �Q�l : OPEN_SYSTEM, CLOSE_SYSTEM, NEW_SYSTEM.


% Copyright 1990-2002 The MathWorks, Inc.
