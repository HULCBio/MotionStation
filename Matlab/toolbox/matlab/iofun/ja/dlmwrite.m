%DLMWRITE ASCII �f���~�^�t���t�@�C���ɏ����o���܂�
%
% DLMWRITE('FILENAME',M) �́A',' ���s��̗v�f�𕪂���f���~�^�Ƃ��Ďg���āA
% �s�� M �� FILENAME �ɏ����o���܂��B
%
% DLMWRITE('FILENAME',M,'DLM') �́A�L�����N�^ DLM ���f���~�^�Ƃ��Ďg���āA
% �s�� M �� FILENAME �ɏ����o���܂��B
%
% DLMWRITE('FILENAME',M,'DLM',R,C) �́A�s�� M ���t�@�C�����ł̃I�t�Z�b�g
% �s R �� �I�t�Z�b�g�� C ���珑���o���܂��BR �� C �̓[������Ƃ��Ă���
% �̂ŁAR=C=0 �́A�t�@�C�����̍ŏ��̐��l���w�肵�܂��B
%
% DLMWRITE('FILENAME',M,'ATTRIBUTE1','VALUE1','ATTRIBUTE2','VALUE2'...)
% DLMWRITE �̃I�v�V�����̈������w�肷�邽�߂ɑ����l�̑g���g�p����A
% �ʂ̌Ăяo���\���ł��B�e�����^�O�ɓK�؂Ȓl�������΁A�����ƒl�̑g
% �̏����͖��ɂȂ�܂���B
%
%	DLMWRITE('FILENAME',M,'-append') �́A�t�@�C���ɍs���ǉ����܂��B
%	���̃t���O���Ȃ��ꍇ�ADLMWRITE �́A�����̃t�@�C���֏㏑�����܂��B
%
%	DLMWRITE('FILENAME',M,'-append','ATTRIBUTE1','VALUE1',...)  
%	�O�̍\���Ɠ��l�ł����A '-append' �t���O�Ɠ��l�ɑ����l�̑g��
%       �󂯎��܂��B���̃t���O�́A�������X�g�̑����l�̑g�̊Ԃ̂ǂ��ɂł�
%�@�@�@ �u�����Ƃ��ł��܂����A���鑮���Ƃ��̒l�̊Ԃɒu�����Ƃ͂ł��܂���B
%
% ���[�U���ݒ�ł���I�v�V����
%
%   ATTRIBUTE : Attribute �^�O���`������p���ň͂܂ꂽ������B 
%               ���� attribute �^�O�g�p�ł��܂��B
%       'delimiter' =>  �s��v�f�𕪂��邽�߂Ɏg�p����f���~�^������
%       'newline'   =>  'pc' ���C���^�[�~�l�[�^�[�Ƃ��� CR/LF ���g�p���܂��B
%                       'unix' ���C���^�[�~�l�[�^�[�Ƃ��� LF ���g�p���܂��B
%       'roffset'   =>  �ړI�t�@�C���̏ォ��f�[�^���������ޏꏊ�܂ł́A
%                       �s�ɂ��Ẵ[������ɂ����I�t�Z�b�g�B
%       'coffset'   =>  �ړI�t�@�C���̍�����f�[�^���������ޏꏊ�܂ł́A
%                       ��ɂ��Ẵ[������ɂ����I�t�Z�b�g�B
%       'precision' =>  �t�@�C���Ƀf�[�^���������ނ��߂Ɏg�p���鐔�l���x�B
%                       �L�������Ƃ��Ă̐��x�A�܂��́A'%10.5f' �̂悤�ɁA
%                       '%' �ł͂��܂�AC-�X�^�C���̏����̕�����B
%                       ����́A�����ۂ߂邽�߂ɃI�y���[�e�B���O�V�X�e����
%                       �W�����C�u�������g�p���邱�Ƃɒ��ӂ��Ă��������B
%
% ���:
%
%   DLMWRITE('abc.dat',M,'delimiter',';','roffset',5,'coffset',6,...
%   'precision',4)  �́A�s��v�f�Ԃ̃f���~�^�Ƃ��āA; ���g�p����
%�@ �t�@�C�� abc.dat �̗�I�t�Z�b�g 5, ��I�t�Z�b�g 6 �ɍs�� M ��
%�@ �����܂��B�f�[�^�̐��l�̐��x�́A4 ����10�i���ɐݒ肳��܂��B
%
%   DLMWRITE('example.dat',M,'-append') �́A�s�� M ���t�@�C�� example.dat
%   �̍Ō�ɒǉ����܂��B�f�t�H���g�ł́Aappend ���[�h�� off, ���Ȃ킿�A
%   DLMWRITE �͊����̃t�@�C���ɏ㏑�����܂��B
%
%   DLMWRITE('data.dat',M,'delimiter','\t','precision',6) �́A�L������ 6
%   �̐��x���g�p���āA�^�u�L�����N�^�ŋ�؂�ꂽ�v�f������ M ���t�@�C��
%   'data.dat' �ɏ����o���܂��B
%   
%   DLMWRITE('file.txt',M,'delimiter','\t','precision','%.6f') �́A�����_
%   �ȉ���6 ���̐��x���g�p���āA�^�u�L�����N�^�ŋ�؂�ꂽ�v�f������ M
%   ���t�@�C�� file.txt �ɏ����o���܂��B
%
%   DLMWRITE('example2.dat',M,'newline','pc') �́APC �v���b�g�t�H�[����
%   �ʏ�̃��C���^�[�~�l�[�^�[���g�p���āA�t�@�C�� example2.dat �� M �������o��
%   �܂��B
%
% �Q�l DLMREAD, CSVWRITE, CSVREAD, WK1WRITE, WK1READ, NUM2STR, 
%   �@ TEXTREAD, TEXTSCAN, STRREAD, IMPORTDATA, SSCANF, SPRINTF.

%   Brian M. Bourgault 10/22/93
%   Modified: JP Barnard, 26 September 2002.
%             Michael Theriault, 6 November 2003 
%   Copyright 1984-2002 The MathWorks, Inc. 
