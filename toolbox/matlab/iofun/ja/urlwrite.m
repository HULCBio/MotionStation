% URLWRITE    URL�̓��e���t�@�C���ɕۑ�
%
% URLWRITE(URL,FILENAME) �́AURL�̓��e���t�@�C���ɕۑ����܂��BFILENAME 
% �́A�t�@�C���̊��S�ȃp�X���w�肷�邱�Ƃ��ł��܂��B�P�Ȃ閼�O�̏ꍇ�́A
% �J�����g�f�B���N�g�����ɍ쐬����܂��B
%
% F = URLWRITE(...) �́A�t�@�C���̃p�X���o�͂��܂��B
%
% F = URLWRITE(...,METHOD,PARAMS) �́A�������N�G�X�g�̈ꕔ�Ƃ��ăT�[�o
% �ɓn���܂��B'method' �� 'get' �܂��� 'post' �ŁAPARAMS �̓p�����[�^�ƒl
% �̑g����Ȃ�Z���z��ł��B
%
% [F,STATUS] = URLWRITE(...) �́A�G���[���L���b�`���A�G���[�R�[�h���o��
% ���܂��B
%
% ���:
%    urlwrite('http://www.mathworks.com/',[tempname '.html'])
%    urlwrite('ftp://ftp.mathworks.com/pub/pentium/Moler_1.txt','cleve.txt')
%    urlwrite('file:///C:\winnt\matlab.ini',fullfile(pwd,'my.ini'))
%
% �t�@�C���[�E�H�[��������̗��p�̏ꍇ�́A�v���t�@�����X�Ńv���L�V�T�[�o
% ��ݒ肵�Ă��������B
% 
% �Q�l �F URLREAD.


%   Matthew J. Simoneau, 13-Nov-2001
%   Copyright 1984-2004 The MathWorks, Inc.
