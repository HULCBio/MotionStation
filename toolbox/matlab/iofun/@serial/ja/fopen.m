% FOPEN   serial port �I�u�W�F�N�g���f�o�C�X�Ɛڑ�
%
% FOPEN(OBJ) �́Aserial port �I�u�W�F�N�g OBJ ���f�o�C�X�Ɛڑ����܂��B
% OBJ �́Aserial port �I�u�W�F�N�g�̔z��ł��B
%
% �����R���t�B�M�����[�V���������� serial port �I�u�W�F�N�g�݂̂��A������
% �@��ɐڑ�����܂��B�Ⴆ�΁A���serial port �I�u�W�F�N�g�݂̂��ACOM2
% �|�[�g�ɓ����ɐڑ��ł��܂��BOBJ �����܂��f�o�C�X�ɐڑ��ł����ꍇ�AOBJ 
% �� Status �v���p�e�B�� open �ɐݒ肳��A���̏ꍇ�AStatus �v���p�e�B��
% closed �ɐݒ肳�ꂽ�܂܂ł��B
%
% OBJ ���I�[�v�������ƁA���̓o�b�t�@�Əo�̓o�b�t�@���Ɏc���Ă���f�[�^��
% �t���b�V������ABytesAvailable, BytesToOutput, ValuesReceived, ValuesSent 
% �v���p�e�B�̓[���ɐݒ肳��܂��B
%
% �������̃v���p�e�B�l�́A�f�o�C�X�ɐڑ����ꂽ��Ɋm�F�����s���܂��B
% ���ɂ� BaudRate, FlowControl, Parity ���܂܂�܂��B�����̃v���p�e�B
% �̂������́A�f�o�C�X�ŃT�|�[�g����Ă��Ȃ��l��ݒ肷��ƁA�G���[��
% �o�͂���A�I�u�W�F�N�g�̓f�o�C�X�Ɛڑ�����܂���B
%
% �������̃v���p�e�B�́Aserial port �I�u�W�F�N�g���I�[�v��(�ڑ�)����
% ����Ԃ͓ǂݍ��ݐ�p�ɂȂ�AFOPEN���g�p����O�ɐݒ肳��Ă��Ȃ����
% �Ȃ�܂���B���́AInputBufferSize �� OutputBufferSize ���܂܂�܂��B
%
% FOPEN ���AOpen �� Status �v���p�e�B�l������ serial port �I�u�W�F�N�g
% ���R�[�������ꍇ�A�G���[���Ԃ���܂��B
%
% �f�o�C�X�̃o�C�g�̏��Ԃ́AOBJ �� ByteOrder �v���p�e�B�Őݒ肷�邱�Ƃ�
% �ł��܂��B
%
% OBJ �� serial port �I�u�W�F�N�g�̔z��ŁA�f�o�C�X�Ɛڑ��ł��Ȃ�
% �I�u�W�F�N�g�̈�ł���ꍇ�A�z����̎c��̃I�u�W�F�N�g�́A�f�o�C�X
% �ɐڑ�����A���[�j���O���\������܂��B
%
% ���:
%       s = serial('COM1');
%       fopen(s);
%       fprintf(s, '*IDN?');
%       idn = fscanf(s);
%       fclose(s);
%
% �Q�l : SERIAL/FCLOSE.


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
