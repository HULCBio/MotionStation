% INSTRFIND   �w�肵���v���p�e�B�l�������� serial port �I�u�W�F�N�g�̌���
%
% OUT = INSTRFIND �́A���������ɑ��݂��Ă��邷�ׂĂ� serial port �I�u
% �W�F�N�g���o�͂��܂��Bserial port �I�u�W�F�N�g�́A�z��Ƃ��āAOUT ��
% �o�͂���܂��B
%
% OUT = INSTRFIND('P1', V1, 'P2', V2,...) �́AP1, V1, P2, V2,...�ƌ���
% �p�����[�^-�l�̑g�œn����� serial port �I�u�W�F�N�g�̃v���p�e�B�l��
% ��v������̂�z�� OUT �ɏo�͂��܂��B�p�����[�^-�l�̑g�́A�Z���z���
% ���Ďw��ł��܂��B
%
% OUT = INSTRFIND(S) �́Aserial port �I�u�W�F�N�g�̃v���p�e�B�l���A�\��
% �� S �̃t�B�[���h����serial port �I�u�W�F�N�g���ƈ�v���āA�t�B�[���h
% �l���K�v�Ƃ����v���p�e�B�l�ł�����̂�z�� OUT ���o�͂��܂��B
%   
% OUT = INSTRFIND(OBJ, 'P1', V1, 'P2', V2,...) �́AOBJ �̒��Ƀ��X�g
% ����� serial port �I�u�W�F�N�g�Ƀp�����[�^-�l�̑g�ƈ�v������̂�
% �T�����܂��BOBJ �́Aserial port �I�u�W�F�N�g�̔z��ł��B
%
% INSTRFIND �ւ̓����R�[���ŁA�p�����[�^-�l�̕�����̑g�A�\���́A
% �p�����[�^-�l�̃Z���z��̑g���g�p���邱�Ƃ��ł��邱�Ƃɒ��ӂ���
% ���������B
%
% �v���p�e�B�l���w�肳���ꍇ�AGET ���o�͂�����̂Ɠ����t�H�[�}�b�g��
% �g�p���Ȃ���΂Ȃ�܂���B���Ƃ��΁AGET ���A'MyObject'�Ɠ��� Name ��
% �o�͂���ꍇ�AINSTRFIND �́A'myobject' �� Name �v���p�e�B�l������
% �I�u�W�F�N�g���������܂���B�������A�v�Z���X�g�f�[�^�^�C�v������
% �v���p�e�B�́A�v���p�e�B�l�̌����ɂ����āA�啶���A�������̋�ʂ��s��
% �܂���B���Ƃ��� INSTRFIND �́AParity �v���p�e�B�l�A'Even' �ł� 
% 'even' �ł��ݒ肵���I�u�W�F�N�g�������ł��܂��B
%
% ���:
%      s1 = serial('COM1', 'Tag', 'Oscilloscope');
%      s2 = serial('COM2', 'Tag', 'FunctionGenerator');
%      out1 = instrfind('Type', 'serial')
%      out2 = instrfind('Tag', 'Oscilloscope')
%      out3 = instrfind({'Port', 'Tag'}, {'COM2', 'FunctionGenerator'})
%
% �Q�l : SERIAL/GET.


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
