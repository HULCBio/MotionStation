% STOPASYNC   �񓯊��ǂ݂��݂Ə������݂̒�~
%
% STOPASYNC(OBJ) �́Aserial port �I�u�W�F�N�g OBJ �Ɛڑ����Ă���f�o�C�X
% ���g���āA�i�s���̔񓯊��ǂ݂��݂⏑�����݉��Z���~���܂��BOBJ �́A
% serial port �I�u�W�F�N�g�̔z��ł��B 
%
% �f�[�^�́A�֐� FPRINTF�@�� FWRITE ���g���āA�񓯊��ŏ������ނ��Ƃ�
% �ł��܂��B�f�[�^�́A�֐� READASYNC ���g���āAReadAsyncMode �v���p�e�B
% �� continuous �ɐݒ肷�邱�ƂŁA�񓯊��I�ɓǂݍ��ނ��Ƃ��ł��܂��B
% �񓯊����Z���́A�v���p�e�B TransferStatus �Ŏ�����܂��B
%
% �i�s���̔񓯊����Z���~������ATransferStatus �v���p�e�B�́Aidle ��
% �ݒ肳��A�o�̓o�b�t�@�͐V�����Ȃ�AReadAsyncMode �v���p�e�B�́Amanual 
% �ɐݒ肳��܂��B
%
% ���̓o�b�t�@�̒��̃f�[�^�́A�V�����Ȃ�܂���B���̃f�[�^�́A�����t����
% �ǂݍ��݊֐��A���Ƃ��΁AFREAD �� FSCANF ���g���āAMATLAB ���[�N�X�y�[�X
% �ɖ߂����Ƃ��ł��܂��B
%
% OBJ ���Aserial port �I�u�W�F�N�g�̔z��ŁA�I�u�W�F�N�g�̈����~����
% ���Ƃ��ł��Ȃ��ꍇ�A�z��̒��̎c��̃I�u�W�F�N�g�͒�~���A���[�j���O��
% �\������܂��B
%
% ���:
%      s = serial('COM1');
%      fopen(s);
%      fprintf(s, 'Function:Shape Sin', 'async');
%      stopasync(s);
%      fclose(s);
%
% �Q�l : SERIAL/READASYNC, SERIAL/FREAD, SERIAL/FSCANF, SERIAL/FGETL,
%        SERIAL/FGETS.


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
