% BALREAL   ��ԋ�Ԏ����̃O���~�A���Ɋ�Â����t��
%
%
% [SYSB,G] = BALREAL(SYS) �́A���`�V�X�e��SYS�̈��蕔���ɑ΂��āA���t����ԋ�
% �Ԏ������v�Z���܂��B����ȃV�X�e���ɑ΂��āA SYSB�́A���B�A�ϑ��O���~�A��
% ���������A�Ίp�`�ł���A�Ίp�v�f��Hankel���ْl�̃x�N�g��G���`������A������
% �����ł��BG �̒��̏����ȗv�f�́A���f�����ȒP�����邽�߂Ɏ�菜�����Ƃ��ł�
% ���Ԃ������܂�(���f����᎟�������邽�߂ɂ́A MODRED ���g�p���܂�)�B
%
% SYS ���s����ȋɂ����ꍇ�A���̈��蕔���������A���t������A���̕s���蕔����
% �t������A�rYSB���`�����܂��B�s���胂�[�h�ɑΉ�����G �̗v�f�́AInf�ɐݒ肳���
% ���BBALREAL(SYS,CONDMAX) ���g�p���āA����/�s���� �����̏�������ύX���܂�
% (�ڍׂ́ASTABSEP �Q��)�B
%
% [SYSB,G,T,Ti] = BALREAL(SYS,...) �́A�t�ϊ� x = Ti*x_b �Ɠ��l�ɁASYS ��
% SYSB�ɕϊ����邽�߂Ɏg�p���ꂽ�A���t����ԕϊ� x_b = T*x ���o�͂��܂��B
%
% �Q�l : MODRED, GRAM, SSBAL, SS


% Copyright 1986-2002 The MathWorks, Inc.
