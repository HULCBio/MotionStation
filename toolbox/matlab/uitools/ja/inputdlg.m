% INPUTDLG   ���̓_�C�A���O�{�b�N�X
% 
% ANSWER = INPUTDLG(PROMPT) �́A�_�C�A���O�{�b�N�X���쐬���A�Z���z��
% ANSWER�ɕ����̃v�����v�g�ɑ΂��郆�[�U���͂��o�͂��܂��B�v�����v�g�́A
% ������ PROMPT ���܂ރZ���z��ł��B
%
% INPUTDLG �́A���[�U����������܂ŁAWAITFOR ���g���Ď��s���~���܂��B
% 
% ANSWER = INPUTDLG(PROMPT,TITLE) �́A�_�C�A���O�̃^�C�g�����w�肵�܂��B
%
% ANSWER = INPUTDLG(PROMPT,TITLE,NUMLINE) �́A�e�X�̓����ɑ΂���s����
% NUMLINE �Ɏw�肵�܂��BNUMLINE �́A�萔�l�܂���1��PROMPT�ɑ΂��āA����
% �ɑ΂��ĉ��s�̃��C�����ݒ肳��Ă���̂�������1�v�f�����x�N�g���ł��B
% NUMLINE �́A�ŏ��̗񂪓��̓t�B�[���h�ɑ΂��Ďw�肷��s���A2�Ԗڂ̗�
% ���̓t�B�[���h�̗񐔂��w�肷��񐔂ł��B
%
% ANSWER = INPUTDLG(PROMPT,NAME,NUMLINE,DEFAULTANSWER) �́A�e�X�� PROMPT 
% �ɑ΂��ĕ\������f�t�H���g�̓������w�肵�܂��BDEFAULTANSWER�́APROMPT
% �Ɠ����v�f���̃Z���z��łȂ���΂Ȃ�܂���B
%
% ANSWER = INPUTDLG(PROMPT,NAME,NUMLINES,DEFAULTANSWER,OPTIONS) �́A
% ���̑��̃I�v�V�������w�肵�܂��BOPTIONS��'on'�ɂł���ꍇ�́A�_�C�A���O��
% ���T�C�Y�\�ł��BOPTIONS���\���̂̏ꍇ���A�t�B�[���hResize, WindowStyle, 
% Interpreter ���F������܂��BResize �́A'on' �܂��� 'off'�ł��BWindowStyle 
% �́A'normal' �܂���' modal'�ł��BInterpreter �́A'none' �܂��� 'tex'
% �ł��BInterpreter ��'tex'�̏ꍇ�́A�v�����v�g������́ALaTeX��p����
% �`�悳��܂��B
%
% ���:
%
%  prompt={'Enter the matrix size for x^2:','Enter the colormap name:'};
%  name='Input for Peaks function';
%  numlines=1;
%  defaultanswer={'20','hsv'};
%
%  answer=inputdlg(prompt,name,numlines,defaultanswer);
%
%  options.Resize='on';
%  options.WindowStyle='normal';
%  options.Interpreter='tex';
%
%  answer=inputdlg(prompt,name,numlines,defaultanswer,options);
%
% �Q�l�F TEXTWRAP, QUESTDLG, UIWAIT.


%  Loren Dean   May 24, 1995.
%  Copyright 1998-2002 The MathWorks, Inc.
