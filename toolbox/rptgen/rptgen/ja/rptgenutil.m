% RPTGENUTIL   report generator�ɑ΂��郆�[�e�B���e�B�@�\���
% RPTGENUTIL�́Areport generator�̔�I�u�W�F�N�g�w�������ŗp�����邢��
% ���̏��������[�e�B���e�B�̃A�N�V�������܂�ł��܂��B
% RPTGENUTIL�́ARPTGENUTIL(ACTION,OPTIONS)�̏����ŌĂяo����܂��B
%
% �A�N�V����:
% 
%   S=RPTGENUTIL('EmptyComponentStructure',COMPONENTNAME)
%
%   N=RPTGENUTIL('SimulinkSystemReportName',SYSNAME)
% 
% SYSNAME�́ASimulink�V�X�e�����A�܂��́A�n���h���ł��BN�́A�V�X�e���ɑ�
% ������ReportName�̖��O�ł��B
%
%   [NUM,ERRORMSG]=RPTGENUTIL('str2numNxN',STRING,OLDNUMBER);
% 
% "2.5x3"�̂悤�ȕ������[2.5 3]�̂悤�Ȑ��l�ɕϊ����܂��B
%
%   [NUM,ERRORMSG] = RPTGENUTIL('str2numNxN',HANDLE,OLDNUMBER);
% 
% ��L�̊֐��̂悤�ɓ��삵�܂����AHANDLE���當����̒l���擾���AHANDLE��
% ��������I�����ɐݒ肵�܂��B
%
%   STR=RPTGENUTIL('num2strNxN',NUM,HANDLE);
% 
% [2.5 3]�̂悤�ȃx�N�g����'2.5x3'�ɕϊ����܂��BHANDLE���^������ꍇ��
% (�I�v�V����)�A�������HANDLE�̃J�����g��'string'�v���p�e�B�ɐݒ肳���
% ���B
%
%   SIZE = RPTGENUTIL('SizeUnitTransform',oldSize,....
%             oldUnits,newUnits,strHandle)
% 
% M�sN��̔z����ȑO�̒P�ʂ���V���ȒP�ʂɕύX���܂��B�I�v�V������uico-
% ntrol�̃n���h���́A�V����M�sN��̒l�̕�����\����\�����܂��B
%
%   [VNAME,ERRORMSG] = RPTGENUTIL('VariableNameCheck',NEWNAME,.....
%               OLDNAME,ISPUNCTOK)  
%  
% �ϐ�(NEWNAME)�ɑ΂��閼�O�A����ѕϐ���(�L���Ɖ��肳���)�ȑO�̖��O��
% �^����Ƃ��ɂ́A�V���ȕϐ����L���Ȗ��O�ł��邱�Ƃ��m�F���܂��B�L���ł�
% ���ꍇ�́A�����I�ɗL���ɂ��܂��B���s�����ꍇ�́A�ȑO�̖��O���o�͂��܂��B
% �n���h��(�I�v�V����)���n�����ꍇ�́A�I�u�W�F�N�g��'String'�v���p�e�B
% ��V���ȕϐ����ɐݒ肵�܂��B
%
% NEWNAME�́Aedit uicontrol�̃n���h���ł��\���܂���B���̏ꍇ�ANEWNAME��
% 'String'�v���p�e�B���瓾���܂��BString�v���p�e�B�́A���̌�C�����ꂽ
% ���O�ɂ���Đݒ肳��܂��B
% 
% ISPUNCTOK�́A�ϐ����ŋ�Ǔ_�L�����N�^��p���邱�Ƃ��ł��邩�ǂ������
% �m����boolean�l�ł��B
% 





%   Copyright (c) 1997-2001 by The MathWorks, Inc. All Rights Reserved.
