% INSTRFIND �@�w�肵���v���p�e�B�l������serial�I�u�W�F�N�g������
%
% OUT = INSTRFIND �́A���݂��Ă��āA���������^�������ׂĂ�serial 
% �I�u�W�F�N�g���o�͂��܂��Bserial�I�u�W�F�N�g�́A�z��Ƃ��� OUT �ɏo
% �͂���܂��B
%
% OUT = INSTRFIND('P1', V1, 'P2', V2,...) �́A�v���p�e�B�̖��O�ƒl���A
% �p�����[�^�ƒl�̑g�AP1, V1, P2, V2,... �œn�������̂ƈ�v����serial
% �I�u�W�F�N�g��z�� OUT �ɏo�͂��܂��B�p�����[�^�ƒl�̑g�́A1�̃Z��
% �z��Ƃ��Ďw�肳��܂��B
%
% OUT = INSTRFIND(S) �́Aserial port�I�u�W�F�N�g�̃v���p�e�B�l���\����  
% S �Œ�`����Ă�����̂ƈ�v���A�t�B�[���h����serial�I�u�W�F�N�g��
% �v���p�e�B���ŁA�t�B�[���h�̒l���v�������v���p�e�B�l�ł�����̂��A
% �z�� OUT �Ƃ��ďo�͂��܂��B
%   
% OUT = INSTRFIND(OBJ, 'P1', V1, 'P2', V2,...) �́APV �g�ɑ΂��錟�����A
% OBJ �̒��Ƀ��X�g���ꂽserial�I�u�W�F�N�g�ɐ������܂��BOBJ �́A�I�u�W�F
% �N�g�̔z��ł��B
%
% INSTRFIND �ւ̓����R�[���ŁAPV ������̑g�A�\���́APV �Z���z��̑g��
% �g�p���邱�Ƃ��ł��邱�Ƃɒ��ӂ��Ă��������B
%
% �v���p�e�B�l���w�肳���ꍇ�AGET ���o�͂�����̂Ɠ����t�H�[�}�b�g��
% �g�p���Ȃ���΂Ȃ�܂���B���Ƃ��΁AGET ��'MyObject'�Ɠ��� Name ���o��
% ����ꍇ�AINSTRFIND �́A'myobject' �� Name �v���p�e�B�l�����I�u�W�F
% �N�g���������܂���B�������A�v�Z���X�g�f�[�^�^�C�v�����v���p�e�B�́A
% �v���p�e�B�l�̌����ɂ����āA�啶���A�������̋�ʂ��s���܂���B���Ƃ��΁A
% INSTRFIND �́AParity �v���p�e�B�l�ɂ����āA'Even'�ł�'even'�Ƃł��ݒ�
% �����I�u�W�F�N�g�������ł��܂��B
% 
% ���F
%      s1 = serial('COM1', 'Tag', 'Oscilloscope');
%      s2 = serial('COM2', 'Tag', 'FunctionGenerator');
%      out1 = instrfind('Type', 'serial')
%      out2 = instrfind('Tag', 'Oscilloscope')
%      out3 = instrfind({'Port', 'Tag'}, {'COM2', 'FunctionGenerator'})
%
% �Q�l�F SERIAL/GET.


%    MP 7-13-99
%    Copyright 1999-2002 The MathWorks, Inc. 
