% XLSREAD Excel ���[�N�u�b�N�̃X�v���b�h�V�[�g����̃f�[�^����уe�L�X�g�̎擾
% [NUMERIC,TXT,RAW]=XLSREAD(FILE,SHEET,RANGE) �́AFILE �Ɏw�肳�ꂽ Excel 
% �t�@�C���̃��[�N�V�[�g SHEET ���� RANGE �Ɏw�肳�ꂽ�f�[�^��ǂݍ��݂܂��B
% FILE �̐��l�Z���́ANUMERIC �ɏo�͂���AFILE �̃e�L�X�g�Z���́ATXT ��
% �o�͂���܂��B�܂��A�������̃Z���̓��e�́ARAW �ɏo�͂���܂��B�f�[�^��
% �͈͂�Θb�I�ɑI�����邱�Ƃ��ł��܂��B (���L�̗����Q��)�BXLSREAD ��
% ���S�ȋ@�\�́AExcel �� MATLAB ���� COM �T�[�o�Ƃ��ċN������@�\�Ɉˑ�����
% ���Ƃɒ��ӂ��Ă��������B
%
% [NUMERIC,TXT,RAW]=XLSREAD(FILE,SHEET,RANGE,'basic') �́A��{���̓��[�h��
% �g�p���āA��L�̂悤�� XLS �t�@�C����ǂݍ��݂܂��B����́AExcel �� COM 
% �T�[�o�Ƃ��ė��p�ł��Ȃ��ꍇ�AWindows ��Ɠ��l�� UNIX �v���b�g�t�H�[���ł�
% �g�p����郂�[�h�ł��B
% ���̃��[�h�ł́AXLSREAD �́AExcel �� COM �T�[�o�Ƃ��Ďg�p���Ȃ����߁A
% �C���|�[�g�@�\�ɐ���������܂��BCOM �T�[�o�Ƃ��� Excel �����p�ł��Ȃ��ꍇ�A
% RANGE ����������A���ʂƂ��āA�V�[�g�̃A�N�e�B�u�Ȕ͈͑S�̂��C���|�[�g����
% �܂��B�܂��A��{���[�h�ŁA�V�[�g�͑啶���Ə���������ʂ��镶����Ƃ���
% �w�肷��K�v������܂��B
%
% ���̓p�����[�^
% FILE: �ǂݍ��݂̃t�@�C�����`���镶����B�f�t�H���g�̃f�B���N�g��
%       �́Apwd �ł��B
%       �f�t�H���g�̊g���q�́A'xls' �ł��BNOTE 1 ���Q�Ƃ��Ă��������B
% SHEET:���[�N�u�b�N FILE �Ń��[�N�V�[�g�����`���镶����
%       ���[�N�u�b�N FILE �̃��[�N�V�[�g�C���f�b�N�X���`���� double �̃X�J���[

% RANGE: ���[�N�V�[�g�Ńf�[�^�͈̔͂��`���镶����B NOTE 2 ���Q�Ƃ���
%        ���������B
% MODE: ��{�I�ȃC���|�[�g���[�h���������镶����B�K�؂Ȓl = 'basic'.
%
% RETURN PARAMETERS:
% NUMERIC = double �^�C�v�� n x m �z��
% TXT = RANGE �Ƀe�L�X�g�Z�����܂� r x s �Z��������z��
% RAW = �������̐��l ����� �e�L�X�g�f�[�^���܂� v x w �Z���z��
% NUMERIC ����� TXT �́ARAW �̃T�u�Z�b�g�ł��B
%
% ���:
%   1. �f�t�H���g�̑���:  
%      NUMERIC = xlsread(FILE);
%      [NUMERIC,TXT]=xlsread(FILE);
%      [NUMERIC,TXT,RAW]=xlsread(FILE);
%
%   2. �f�t�H���g�̗̈悩��̃f�[�^�̎擾
%      NUMERIC = xlsread('c:\matlab\work\myspreadsheet')
%
%   3. �ŏ��̃V�[�g�ȊO�̃V�[�g�̎g�p�����̈悩��̃f�[�^�̎擾:
%      NUMERIC = xlsread('c:\matlab\work\myspreadsheet','sheet2')
%
%   4. �V�[�g�����w�肵�āA�f�[�^���擾
%      NUMERIC = xlsread('c:\matlab\work\myspreadsheet','NBData')
%
%   5. �ŏ��̃V�[�g�ȊO�̃V�[�g�̎w�肵���̈悩��̃f�[�^�̎擾
%      NUMERIC = xlsread('c:\matlab\work\myspreadsheet','sheet2','a2:j5')
% 
%   7. �w�肵�����O�̃V�[�g�̎w��̈悩��̃f�[�^�̎擾
%      NUMERIC = xlsread('c:\matlab\work\myspreadsheet','NBData','a2:j5')
% 
%   8. �C���f�b�N�X�ɂ��w�肵���V�[�g�̈悩��̃f�[�^�̎擾
%      NUMERIC = xlsread('c:\matlab\work\myspreadsheet',2,'a2:j5')
% 
%   9. �Θb�ɂ��̈�̑I��:
%      NUMERIC = xlsread('c:\matlab\work\myspreadsheet',-1);
%      �t�H�[�J�X����� EXCEL �E�B���h�E���ŁA�A�N�e�B�u�ȗ̈��
%      �A�N�e�B�u�ȃV�[�g��I������K�v������܂��B
%      �A�N�e�B�u�ȗ̈�̑I�����I������Ƃ��AMatlab �R�}���h���C����
%      ������������͂��Ă��������B
%
% ���� 1: FILE ����̕�����܂��͏ȗ������ꍇ�A�G���[���������܂��B
% ���� 2: ���[�N�u�b�N�̍ŏ��̃��[�N�V�[�g���A�f�t�H���g�̃V�[�g�ł��B
%         SHEET �� -1 �̏ꍇ�AExcel ���O�ɕ\������A�Θb�I�ȑI�����ł��܂�
%         (�I�v�V����)�B�Θb�I�ȃ��[�h�ł́A�_�C�A���O�����[�U�� �_�C�A���O
%         ���� OK �{�^�����N���b�N����悤�ɑ����AMATLAB �ő������܂��B
% ���� 3: �W���I�ɂ́A���̂悤�ɂȂ�܂��B
%         'D2:F3' ���[�N�V�[�g���̒����`�̗̈� D2:F3 ��I�����܂��B
%         RANGE �́A�啶���Ə������̋�ʂ͂����AExcel A1 �̋L��
%         ���g�p���܂� (Excel Help ���Q��)�B
%
% �Q�l XLSWRITE, CSVREAD, CSVWRITE, DLMREAD, DLMWRITE, TEXTREAD.

%   JP Barnard
%   Copyright 1984-2002 The MathWorks, Inc.
