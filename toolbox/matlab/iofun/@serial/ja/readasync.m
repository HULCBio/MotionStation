% READASYNC   �f�o�C�X����񓯊���ԂŃf�[�^��ǂݍ���
%
% READASYNC(OBJ) �́Aserial port �I�u�W�F�N�g OBJ �ɐڑ����ꂽ�f�o�C�X
% ����񓯊���ԂŁA�f�[�^��ǂݍ��݂܂��BREADASYNC �́A�R���g���[�����A
% ���̌�A������ MATLAB �ɖ߂��܂��B
%
% �ǂݍ��񂾃f�[�^�́A���̓o�b�t�@�ɃX�g�A����܂��BBytesAvailable �v��
% �p�e�B�́A���̓o�b�t�@���ŗ��p�\�ȃo�C�g���������܂��B
%
% READASYNC �́A���Ɏ����̓��̈��������Ɠǂݍ��݂��~���܂��B:
%     1. Terminator �v���p�e�B�Ŏw�肳�ꂽ�I�[�q���󂯎��
%     2. Timeout �v���p�e�B�Ŏw�肳�ꂽ���Ԑ؂ꂪ��������
%     3. ���̓o�b�t�@�������ς��ɂȂ�
% 
% serial port �I�u�W�F�N�g OBJ �́A�C�ӂ̃f�[�^���f�o�C�X����ǂݍ��܂��
% �O�� FOPEN �֐����g���ăf�o�C�X�ɐڑ����Ă��Ȃ���΂Ȃ�܂���B���̑���
% �ꍇ�́A�G���[���o�͂���܂��B�ڑ����ꂽ serial port �I�u�W�F�N�g�́A
% open �� Status �v���p�e�B�l�������Ă��܂��B
%
% READASYNC(OBJ, SIZE) �́A�f�o�C�X����A�����Ă� SIZE �o�C�g��ǂݍ���
% �܂��B
% SIZE �� OBJ �� InputBufferSize �v���p�e�B�l�� OBJ �� BytesAvailable
% �v���p�e�B�l�̍��������傫���ꍇ�A�G���[���Ԃ���܂��B
%
% TransferStatus �v���p�e�B�́A�񓯊��I�ȑ��삪�i�s�����ۂ��������܂��B
%
% �񓯊��I�ȓǂݍ��݂̐i�s���� READASYNC ���R�[�����ꂽ�ꍇ�A�G���[��
% �o�͂���܂��B�������A�񓯊��I�ȓǂݍ��݂��i�s���Ă���Ԃ̏������݂�
% �\�ł��B
%
% STOPASYNC �֐��́A�񓯊��I�ȓǂݍ��ݑ�����~����̂Ɏg���܂��B
%
% ���:
%      s = serial('COM1', 'InputBufferSize', 5000);
%      fopen(s);
%      fprintf(s, 'Curve?');
%      readasync(s);
%      data = fread(s, 2500);
%      fclose(s);
%      
% �Q�l : SERIAL/FOPEN, SERIAL/STOPASYNC.


% MP 12-30-99
% Copyright 1999-2004 The MathWorks, Inc. 
