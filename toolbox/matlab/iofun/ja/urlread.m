% URLREAD    URL�̓��e�𕶎���Ƃ��ďo��
%
%  S = URLREAD('URL') �́AURL�̓��e�𕶎��� S �ɓǂݍ��݂܂��B�T�[�o���o
% �C�i���f�[�^���o�͂���ꍇ�́A������ɂ̓K�[�x�[�W���܂܂�܂��B
%
%  S = URLREAD('URL','method',PARAMS) �́A�������N�G�X�g�̈ꕔ�Ƃ��ăT�[
% �o�ɓn���܂��B'method' �� 'get' �܂��� 'post' �ŁAPARAMS �̓p�����[�^�ƒl��
% �g����Ȃ�Z���z��ł��B
%
% [S,STATUS] = URLREAD(...) �́A�G���[���L���b�`���A�t�@�C���̃_�E�����[�h��
% ���������ꍇ�� 1 ���A����ȊO�� 0 ��Ԃ��܂��B
%
% ���:
%    s = urlread('http://www.mathworks.com');
%    s = urlread('ftp://ftp.mathworks.com/pub/pentium/Moler_1.txt')
%    s = urlread('file:///C:\winnt\matlab.ini')
%
% �t�@�C���[�E�H�[��������̗��p�̏ꍇ�́A�v���t�@�����X�Ńv���L�V�T�[�o
% ��ݒ肵�Ă��������B
% 
% �Q�l �F URLWRITE.


%   Matthew J. Simoneau, 13-Nov-2001
%   Copyright 1984-2004 The MathWorks, Inc.

