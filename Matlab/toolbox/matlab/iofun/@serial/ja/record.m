% RECORD   �f�[�^�ƃC�x���g�����t�@�C���ɋL�^
%
% RECORD(OBJ) �́A�I�u�W�F�N�g OBJ �� RecordStatus �v���p�e�B���Aon ��
% off �ɐ؂�ւ��܂��BRecordStatus �� on �̏ꍇ�A�f�o�C�X�ɃR�}���h��
% �������܂�A�f�o�C�X����f�[�^���ǂݍ��܂�A�C�x���g��� OBJ ��
% RecordName �v���p�e�B�Ŏw�肳�ꂽ�t�@�C���ɋL�^����܂��BRecordStatus
% �� off �̏ꍇ�A���͋L�^����܂���BOBJ �́A1�s1��� serial port 
% �I�u�W�F�N�g�łȂ���΂Ȃ�܂���B�f�t�H���g�́AOBJ�� RecordStatus 
% �́Aoff �ł��B
%
% serial port �I�u�W�F�N�g�́ARecordStatus ���ύX�����O�ɁAFOPEN 
% �R�}���h�Ƌ��Ƀf�o�C�X�ɐڑ�����Ȃ���΂Ȃ�܂���B�ڑ����ꂽ serial 
% port �I�u�W�F�N�g�́Aopen �� Status �v���p�e�B�l�������܂��B
%
% �L�^�t�@�C���́AASCII �t�@�C���ł��BOBJ �� RecordDetail �v���p�e�B��
% �R���p�N�g�ɐ݌v����A�L�^�t�@�C���́A�f�o�C�X����ǂݍ��܂ꂽ�l�̐��A
% �f�o�C�X�ɏ������܂�Ă���l�̐��A�C�x���g��񂪊܂܂�܂��BOBJ ��
% RecordDetail �v���p�e�B���Averbose �ɐݒ肳��Ă���ꍇ�A�L�^�t�@�C���́A
% �f�o�C�X����ǂݍ��܂ꂽ�A�܂��̓f�o�C�X�ɏ������܂ꂽ�f�[�^���܂܂�
% �܂��B
%
% uchar, schar, (u)int8, (u)int16, (u)int32 �̐��x�̃o�C�i���f�[�^�́A
% 16�i�@�ŋL�^�t�@�C���ɋL�^����Ă��܂��B���Ƃ��΁A255�� int16 �l�́A
% �@�킩��ǂݍ��܂�A�l 00FF ���L�^�t�@�C���ɋL�^����܂��B�P���x�A
% �{���x�Ńo�C�i���f�[�^���AIEEE 754 ���������_�r�b�g�z��ɏ]���āA
% �L�^����܂��B 
%
% RECORD(OBJ, 'STATE') �́ARecordStatus �v���p�e�B�l�� STATE ��ݒ肵��
% �I�u�W�F�N�g OBJ �����܂��BSTATE �́A'on'�A�܂��́A'off'�̂ǂ��炩
% �ł��B
%
% �I�u�W�F�N�g RecordStatus �v���p�e�B�l�́A�I�u�W�F�N�g�� FLCLOSE �R�}
% ���h�����n�[�h�E�F�A����̐ڑ����؂ꂽ�Ƃ��Aoff �Ɏ����I�ɕς��܂��B
%
% RecordName �� RecordMode �v���p�e�B�́AOBJ���L�^���̂Ƃ��A�ǂݍ��݂̂�
% �ɂȂ�܂��B�����̃v���p�e�B�́ARECORD ���g���O�ɁA�ݒ肳��Ă��Ȃ����
% �Ȃ�܂���B
%
% ���:
%       s = serial('COM1');
%       fopen(s)
%       set(s, 'RecordDetail', 'verbose')
%       record(s, 'on');
%       fprintf(s, '*IDN?')
%       fscanf(s);
%       fclose(s);
%       type record.txt
%
% �Q�l : SERIAL/FOPEN, SERIAL/FCLOSE.


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
