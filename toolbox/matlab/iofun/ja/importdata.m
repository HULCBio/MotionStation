% IMPORTDATA   �f�B�X�N���烏�[�N�X�y�[�X�ϐ������[�h
%
% IMPORTDATA(FILENAME) �́AFILENAME ���烏�[�N�X�y�[�X�Ƀf�[�^�����[�h
% ���܂��B
% A = IMPORTDATA(FILENAME) �́AFILENAME ����f�[�^�� A �Ƀ��[�h���܂��B
%
% IMPORTDATA(FILENAME, D) �́A���؂�q�Ƃ��� D ���g���āAFILENAME 
% ����f�[�^�����[�h���܂��B�^�u�ɂ́A'\t'���g���܂��B
%
% IMPORTDATA �́A�g�p����⏕�֐������肷�邽�߂ɁA�t�@�C���g���q�𒲂�
% �܂��B�g���q�� FILEFORMATS �ŋL����Ă���ꍇ�AIMPORTDATA �́A�o��
% �����̍ő吔����舵���K�؂ȕ⏕�֐����R�[�����܂��B�g���q�� 
% FILEFORMATS �ɋL����Ă��Ȃ��ꍇ�́AIMPORTDATA ��FINFO ���R�[�����A
% �g�p����⏕�֐������肵�܂��B�⏕�֐����g���q�ɑ΂��Č���ł��Ȃ���
% ���́AIMPORTDATA �͋�؂�q�����e�L�X�g�Ƃ��ăt�@�C���������܂��B
% �⏕�֐�����̋�̏o�͂͌��ʂ��珜������܂��B
%
% ����: �C���|�[�g�����t�@�C����ASCII�e�L�X�g�t�@�C���ŁA�܂��A
% IMPORTDATA ���t�@�C���̃C���|�[�g�ɖ�肪����ꍇ�AIMPORTDATA ����
% TEXTSCAN �̃V���v���ȃA�v���P�[�V���������A���ׂ��������̐ݒ��
% �g���� TEXTSCAN �������Ă��������B
% ����: ���Â� Excel �̏����̓ǂݍ��݂Ɏ��s�����ꍇ�AExcel �t�@�C����
% Excel 2000 �܂��� 95 �̏����Ƃ��ĊJ�����ƂōX�V���邩�AExcel 2000 
% �܂��� Excel 95 �Ƃ��ĕۑ����Ă��������B
%
% ���F
%
%    s = importdata('ding.wav')
% s =
%
%    data: [11554x1 double]
%      fs: 22050
%
%   s = importdata('flowers.tif');
%   size(s)
% ans =
%
%    362   500     3
%
% �Q�l�F LOAD, FILEFORMATS, TEXTSCAN


% Copyright 1984-2002 The MathWorks, Inc.
