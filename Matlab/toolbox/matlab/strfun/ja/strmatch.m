% STRMATCH   �K�����镶����̌��o
% 
% I = STRMATCH(STR,STRS) �́A������ STRS �̃L�����N�^�z��܂��̓Z���z��
% �̍s���������A������ STR ����n�܂镶����������A���̓K�������s��
% �C���f�b�N�X���o�͂��܂��B
% STRMATCH �́ASTRS ���L�����N�^�z��̂Ƃ��A�ł������ł��B
%
% I = STRMATCH(STR,STRS,'exact') �́ASTRS ���� STR �Ɗ��S�Ɉ�v���Ă���
% ������̃C���f�b�N�X�݂̂��o�͂��܂��B
%
% ���
% 
% i = strmatch('max',strvcat('max','minimax','maximum'))�́A1�s�ڂ�3�s�ڂ�
% 'max' ����n�܂邽�߁Ai = [1; 3] ���o�͂��܂��B
% 
% i = strmatch('max',strvcat('max','minimax','maximum'),'exact')�́A
% 1�s�ڂ݂̂� 'max' �Ɛ��m�Ɉ�v���邽�߁Ai = 1 ���o�͂��܂��B
%   
% �Q�l�FSTRFIND, STRVCAT, STRCMP, STRNCMP.


%   Mark W. Reichelt, 8-29-94
%   Copyright 1984-2002 The MathWorks, Inc. 
