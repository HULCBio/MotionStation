% TBLREAD   tabular�`���̃f�[�^�̓ǂݍ���
%
% [DATA, VARNAMES, CASENAMES] = TBLREAD �́A�Θb�`���őI�����ꂽ�t�@�C��
% ����f�[�^��ǂݍ��݂܂��B�t�@�C���̓��e�́A�ŏ��̍s�̒��̕ϐ�(��)���ŁA
% �ŏ��̗񂪖��O(�s)�ŁA(2,2)���X�y�[�X�L�����N�^�ŋ�؂��鐔�l�f�[�^
% �̊J�n�_�ɂȂ�܂��B
%
% [DATA, VARNAMES, CASENAMES] = TBLREAD(FILENAME) �́A�w�肳�ꂽ�t�@�C��
% ����p���ē��l�Ƀf�[�^��ǂݍ��݂܂��BFILENAME �́A��]����t�@�C����
% �����p�X�������S�Ɋ܂�ł��Ȃ���΂Ȃ�܂���B
%
% [DATA, VARNAMES, CASENAMES] = TBLREAD(FILENAME,DELIMITER) �́A�f���~�^
% �̃L�����N�^�Ƃ��� DELIMITER ��p���ăt�@�C������ǂݍ��݂��s���܂��B
% DELIMITER �ɂ́A���̒l�̂����ꂩ��ݒ肷�邱�Ƃ��ł��܂��B
%   ' ', '\t', ',', ';', '|' �܂��́A����ɑΉ����镶���񖼁A
%   'space', 'tab', 'comma', 'semi', 'bar'; 
%   'space' ���f�t�H���g�ł��B
%
% VARNAMES �́A�ŏ��̍s�̒��̕ϐ���(��̖��O)���܂񂾕����s��ł��B
%
% CASENAMES �́A�ŏ��̗�̒��̌X�̃P�[�X��(�s�̖��O)���܂ޕ����s��ł��B
%
% DATA �́A�e�ϐ��ƃP�[�X�����y�A�ɂȂ������̂ɑ΂���l�������l�s��ł��B
%
% ���l/�e�L�X�g�����݂����f�[�^��ǂݍ��ނɂ́ATDFREAD ���g�p���Ă��������B
%
% �Q�l : TDFREAD.


%   Copyright 1993-2003 The MathWorks, Inc. 
% $Revision: 1.6 $  $Date: 2003/02/12 17:15:58 $
