%INSTRFINDALL �w�肵���v���p�e�B�l�������ׂĂ� serial port �I�u�W�F�N�g
%             ������
%
% OUT = INSTRFINDALL �́A�I�u�W�F�N�g�� ObjectVisibility �v���p�e�B�l�A
% �Ɉ˂炸�������ɂ��邷�ׂĂ� serial port �I�u�W�F�N�g���o�͂��܂��B
% serial port �I�u�W�F�N�g�́A�z��Ƃ���OUT �ɏo�͂���܂��B
%
% OUT = INSTRFINDALL('P1', V1, 'P2', V2,...) �́Aserial port 
% �I�u�W�F�N�g�����A�z�� OUT ���o�͂��܂��B���̃I�u�W�F�N�g��
% �v���p�e�B���ƃv���p�e�B�l�́A�p�����[�^�ƒl�̑g�AP1, V1, P2, V2,..
% �Ƃ��ēn�������̂Ɉ�v���܂��B �p�����[�^�ƒl�̑g�́A�Z���z��Ƃ���
% �w�肷�邱�Ƃ��ł��܂��B
%
% OUT = INSTRFINDALL(S) �́Aserial port �I�u�W�F�N�g�̃v���p�e�B�l��
% �\���� S �ɒ�`���ꂽ���̂ƈ�v����A�z��AOUT���o�͂��܂��B
% ���̍\���̂̃t�B�[���h���� serial port �I�u�W�F�N�g�v���p�e�B���ł���A
% �t�B�[���h�̒l���K�v�Ƃ����v���p�e�B�l�ł��B
%   
% OUT = INSTRFINDALL(OBJ, 'P1', V1, 'P2', V2,...) �́AOBJ �Ƀ��X�g�����
% serial port �I�u�W�F�N�g�Ƀp�����[�^�ƒl�̑g�ƈ�v������̂Ɍ����𐧌�
% ���܂��BOBJ �́Aserial port �I�u�W�F�N�g�̔z��ɂȂ�܂��B
%
% INSTRFIND �ւ̓����R�[���ŁA�p�����[�^-�l�̕�����̑g�A�\���́A
% �p�����[�^-�l�̃Z���z��̑g���g�p���邱�Ƃ��ł��邱�Ƃɒ��ӂ���
% ���������B
%
% �v���p�e�B�l���w�肳���ꍇ�AGET �̏o�͂Ɠ����t�H�[�}�b�g���g�p����
% �K�v������܂��B���Ƃ��΁AGET �� Name �� 'MyObject' �Ƃ��ďo�͂���ꍇ�A
% INSTRFIND �́A'myobject' �Ƃ��� Name �v���p�e�B�l�����I�u�W�F�N�g��
% �������܂���B�������A���ׂ�ꂽ���X�g�̃f�[�^�^�C�v�����v���p�e�B�́A
% �v���p�e�B�l����������ہA�啶���Ə���������ʂ��܂���B���Ƃ��΁A
% INSTRFIND �́A'Even' �܂��� 'even' �� Parity �v���p�e�B�l������
% �I�u�W�F�N�g���������܂��B
%
% ���:
%       s1 = serial('COM1', 'Tag', 'Oscilloscope');
%       s2 = serial('COM2', 'Tag', 'FunctionGenerator');
%       set(s1, 'ObjectVisibility', 'off');
%       out1 = instrfind('Type', 'serial')
%       out2 = instrfindall('Type', 'serial');
%
% �Q�l SERIAL/GET, SERIAL/INSTRFIND.
%

% MP 9-19-02
% Copyright 1999-2004 The MathWorks, Inc. 
