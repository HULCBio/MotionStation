% FCLOSE   �f�o�C�X���� serial port �I�u�W�F�N�g�̐ؒf
%
% FCLOSE(OBJ) �́A�f�o�C�X���� serial port �I�u�W�F�N�g OBJ ��ؒf���܂��B
% OBJ �́Aserial port �I�u�W�F�N�g�̔z��ł��B
%
% OBJ ���f�o�C�X���炤�܂��ؒf���ꂽ�ꍇ�AOBJ �� Status �v���p�e�B�́A
% closed �ɐݒ肳��ARecordStatus �v���p�e�B�́Aoff �ɐݒ肳��܂��B
% OBJ �́A�֐� FOPEN ���g���āA�f�o�C�X�ɍČ�������܂��B
%
% �f�[�^���f�o�C�X�ɔ񓯊��I�ɏ������܂�Ă���ԁA�I�u�W�F�N�g��ؒf����
% ���Ƃ͂ł��܂���BSTOPASYNC �֐��́A�񓯊��I�ȏ������݂𒆎~���邽�߂�
% �g���܂��B
%
% OBJ �́Aserial port �I�u�W�F�N�g�̔z��ŁA�I�u�W�F�N�g�̈���f�o�C�X
% ����ؒf�ł��Ȃ��ꍇ�A�z����̎c��̃I�u�W�F�N�g�́A�f�o�C�X����ؒf
% ����A���[�j���O��\�����܂��B
%
% ���:
%       s = serial('COM1');
%       fopen(s);
%       fprintf(s, '*IDN?');
%       idn = fscanf(s);
%       fclose(s);
%
% �Q�l : SERIAL/FOPEN, SERIAL/STOPASYNC.


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
