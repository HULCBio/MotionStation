% SIMPRINTDLG   �v�����g�_�C�A���O�{�b�N�X
%
% SIMPRINTDLG(sys) �́A�V�X�e�� sys ���v�����g����_�C�A���O�{�b�N�X���쐬��
% �܂��BSIMPRINTDLG �́A�J�����g�̃V�X�e�����v�����g���܂��B
% sys �́A�n���h���܂��͕�����̖��O�ł��B
%
% SIMPRINTDLG('-crossplatform',sys) �́APC�A����сAMacintosh�̑g�ݍ��݃v����
% �g�_�C�A���O�ł͂Ȃ��A�W���̃N���X�v���b�g�t�H�[��MATLAB�v�����g�_�C�A���O
% ��\�����܂��B���̃I�v�V�����́A����ȊO�̃I�v�V�����̑O�ɑ}������܂��B
%
%
% ���̃I�v�V�����́A�R�}���h���C���ŗ��p���邱�Ƃ��Ӑ}���Ă��܂��B
% �v�����g�_�C�A���O�͊J���܂���B
%
% [Systems,PrintLog] = .... SIMPRINTDLG(Sys,SysOpt,LookUnderMask,
% Systems     - �v�����g���� System �̃n���h���̃��X�g�ƃv�����g�̏��ԁB S
%               tateflow�̃n���h�����܂݂܂��B
% Stateflow�̃n���h���́A�v�����g����ƁA�폜����K�v������܂��B
% PrintLog    - �v�����g���O�̃e�L�X�g�o�[�W�����B
%
% Sys �́A�v�����g�_�C�A���O���N�����ꂽ�V�X�e���ł��B
%
% SysOpt �́A'CurrentSystem'        , 'CurrentSystemAndAbove','
% CurrentSystemAndBelow', 'AllSystems'�ł��B
%
% LookUnderMask �́A�}�X�N�̉��w��\�����Ȃ��ꍇ��0�ŁA���ׂẴV�X�e����\��
% ����ꍇ��1�ł��B
%
% ExpandLibLinks �́A�ŏ��̃��C�u���������N�Œ�~����ꍇ��0�ŁA�����N�̉��w
% ��\������ꍇ��1�ł��B
%
%
% SIMPRINTDLG(Sys,SysOpt,LookUnderMask,ExpandLibLinks,PrintInfo)�ŁA
% PrintInfo �́A���̃t�B�[���h�APrintLog, PrintFrame, FileName,
% PrintOptions, PaperType, PaperOrientation�����f�[�^�\���̂ł��B
% PrintLog, PrintFrame, FileName, PrintOptions, PaperType,
% PaperOrientation.
%
% PrintLog ��'on'�ł���ꍇ�́A���O�t�@�C�����v�����g����܂��B
% PrintLog�� 'off'�܂��� '' �ł���ꍇ�́A���O�t�@�C���̓v�����g����܂���B
%
% PrintFrame ���A'' �ł���ꍇ�́A�v�����g�W���u�Ƀv�����g�t���[���͊܂܂�܂���
% �B�����łȂ��ꍇ�APrintFrame ����łȂ��A�L����printframe�t�@�C���ł���ꍇ
% �́Aprintframes�͏o�͂Ɋ܂܂�܂��B
%
% FileName ����̏ꍇ���A�o�͂��v�����g����܂��B
% FileName ����łȂ��ꍇ�́A�o�͂� FileName �Ƃ������O�ŁA�K�؂Ȋg���q(��
% txt, ps, eps)�����t�@�C���ɕۑ�����܂��Btxt, ps, eps).
%
% PaperType �� PaperOrientation �́A�����̃v���p�e�B�ɑ΂���L���Ȑݒ�̂�
% ���ꂩ�ō\���܂���B
%
% PrintOptions �́Aprint�R�}���h�Ɏw�肵���v�����g�I�v�V������t�����܂��B
%
% ���� PrintData �\���̗̂�́Aencapsulated postscript ��p���āA�v�����g��
% �O���܂܂��Aprintframe�����t�@�C�����o�͂��܂��B PrintData.PrintLog='
% off'; PrintData.PrintFrame='sldefaultframe.fig'; PrintData.FileName='
% myprintoutput'; PrintData.PrintOptions='-deps'; PrintData.
% PaperOrientation='landscape'; PrintData.PaperType='usletter';
%
% �Q�l : SIMPRINTLOG, FRAMEEDIT, PRINT.


% Copyright 1990-2002 The MathWorks, Inc.
