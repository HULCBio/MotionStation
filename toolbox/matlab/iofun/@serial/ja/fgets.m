% FGETS   �I�[�q��ێ������܂܃f�o�C�X����e�L�X�g��1�s��ǂݍ���
%
% TLINE=FGETS(OBJ) �́Aserial port �I�u�W�F�N�g OBJ �ɐڑ����Ă���
% �f�o�C�X����e�L�X�g��1�s��ǂݍ��݁ATLINE �ɏo�͂��܂��B�o�̓f�[�^�́A
% �e�L�X�g�̃��C���ɏI�[�q���܂݂܂��B�I�[�q�������ɂ́AFGETL ���g�p����
% ���������B
%    
% FGETS �́A���̎����̓��̈��������ƃu���b�N����܂��B:
%     1. Terminator �v���p�e�B�Ŏw�肳�ꂽ�I�[�q���󂯎��
%     2. Timeout �v���p�e�B�Ŏw�肳�ꂽ���Ԑ؂ꂪ��������
%     3. ���̓o�b�t�@�������ς��ɂȂ�
%
% serial port �I�u�W�F�N�g OBJ �́A�C�ӂ̃f�[�^���f�o�C�X����ǂݍ��܂��
% �O�� FOPEN �֐����g���ăf�o�C�X�ɐڑ����Ă��Ȃ���΂Ȃ�܂���B���̑���
% �ꍇ�́A�G���[���o�͂���܂��B�ڑ����ꂽ serial port �I�u�W�F�N�g�́A
% open �� Status �v���p�e�B�l�������Ă��܂��B
%
% [TLINE,COUNT]=FGETS(OBJ) �́ACOUNT �ɓǂݍ��񂾒l�̔ԍ����o�͂��܂��B
% COUNT �́A�I�[�q���܂݂܂��B
%
% [TLINE,COUNT,MSG]=FGETS(OBJ) �́AFGETS �����S�ɂ��܂��@�\���Ȃ��ꍇ�A
% ���b�Z�[�W MSG ���o�͂��܂��BMSG ���w�肳��Ă��Ȃ��ꍇ�A���[�j���O��
% �R�}���h���C���ɕ\������܂��B
%
% OBJ �� ValuesReceived �v���p�e�B�́A�I�[�q���܂܂��A�f�o�C�X����
% �ǂݍ��܂ꂽ�l�̔ԍ��ɂ���čX�V����܂��B
%
% OBJ �� RecordStatus property �́ARECORD �֐��� on �ɐݒ肳��Ă���
% �ꍇ�A�f�[�^���󂯎���� TLINE �́AOBJ �� RecordName �v���p�e�B�l��
% �w�肳�ꂽ�t�@�C�����ɋL�^����܂��B
% 
% ���:
%       s = serial('COM1');
%       fopen(s);
%       fprintf(s, '*IDN?');
%       idn = fgets(s);
%       fclose(s);
%       delete(s);
%
% �Q�l : SERIAL/FGETL, SERIAL/FOPEN, SERIAL/RECORD.



% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
