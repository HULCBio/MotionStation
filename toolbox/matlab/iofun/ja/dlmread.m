% DLMREAD   ASCII�f���~�^�t���t�@�C�����s��Ƃ��ēǂݍ��݂܂�
% RESULT = DLMREAD(FILENAME) �́AASCII�f���~�^�t���t�@�C�� FILENAME ����
% ���l�f�[�^��ǂݍ��݂܂��B  �f���~�^�́A�t�@�C���̏������琄������܂��B
% 
% RESULT = DLMREAD(FILENAME,DELIMITER) �́A�f���~�^ DELIMITER ��
% �g���āAASCII�f���~�^�t���t�@�C�� FILENAME ����f�[�^��ǂݍ��݂܂��B
% ���ʂ́ARESULT �ɏo�͂���܂��B�^�u���w�肷�邽�߂ɂ́A'\t'���g����
% ���������B
%
% �f���~�^���A�t�@�C���̏������琄�������ꍇ�A�A������󔒂�1��
% �f���~�^�Ƃ��Ď�舵���܂��B����ɑ΂��āA�f���~�^�� DELIMITER 
% ���͂ɂ��w�肳���ꍇ�A�J��Ԃ����f���~�^�����͕ʁX�̃f���~�^
% �Ƃ��Ď�舵���܂��B
%
% RESULT = DLMREAD(FILENAME,DELIMITER,R,C) �́ADELIMITER�f���~�^�t�@�C��
% FILENAME ����f�[�^��ǂݍ��݂܂��BR �� C �́A�t�@�C�����̃f�[�^��
% ������̈ʒu�ł���s R �Ɨ� C ���w�肵�܂��BR �� C �́A�[�������
% ���Ă���̂ŁAR = 0 �� C = 0 �́A�t�@�C�����̍ŏ��̒l���w�肵�܂��B
%
% RESULT = DLMREAD(FILENAME,DELIMITER,RANGE) �́A(R1,C1) ��������ŁA
% (R2,C2) ���E�����̂Ƃ��ARANGE = [R1 C1 R2 C2] �Ŏw�肳���͈݂͂̂�
% �ǂݍ��݂܂��BRANGE �́ARANGE = 'A1..B7 '�̂悤�ȃX�v���b�h�V�[�g
% �̕\�L�@���g���Ă��w��ł��܂��B
%
% DLMREAD �́A��̃f���~�^�t�B�[���h��0�ɐݒ肵�܂��B�X�y�[�X�̂Ȃ��f��
% �~�^�Ń��C�����I�����Ă���f�[�^�t�@�C���́A���ׂĂ̗v�f���[���Őݒ�
% ��������ŏI��ɒǉ��������ʂ��쐬���܂��B
%
% �Q�l DLMWRITE, TEXTSCAN, TEXTREAD, LOAD, FILEFORMATS

%   Copyright 1984-2002 The MathWorks, Inc.
