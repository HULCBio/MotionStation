% FSCANF   �f�o�C�X�ƃt�H�[�}�b�g�t���e�L�X�g����f�[�^��ǂݍ���
%
% A=FSCANF(OBJ) �́Aserial port �I�u�W�F�N�g OBJ �ɐڑ����Ă���f�o�C�X
% ����f�[�^��ǂݍ��݁A�t�H�[�}�b�g�t���̃e�L�X�g�f�[�^�Ƃ��� A �ɏo��
% ���܂��B
%
% FSCANF �́A���̎����̓��̈��������ƃu���b�N����܂��B:
%     1. Terminator �v���p�e�B�Ŏw�肳�ꂽ�I�[�q���󂯎��
%     2. Timeout �v���p�e�B�Ŏw�肳�ꂽ���Ԑ؂ꂪ��������
%     3. ���̓o�b�t�@�������ς��ɂȂ�
%
% serial port �I�u�W�F�N�g OBJ �́A�C�ӂ̃f�[�^���f�o�C�X����ǂݍ��܂��
% �O�� FOPEN �֐����g���ăf�o�C�X�ɐڑ����Ă��Ȃ���΂Ȃ�܂���B���̑���
% �ꍇ�́A�G���[���o�͂���܂��B�ڑ����ꂽ serial port �I�u�W�F�N�g�́A
% open �� Status �v���p�e�B�l�������Ă��܂��B
%
% A=FSCANF(OBJ,'FORMAT') �́Aserial port �I�u�W�F�N�g OBJ �ɐڑ�����
% ����f�o�C�X����f�[�^��ǂݍ��݁A�w�肵�� FORMAT ������ɏ]���āA
% �ϊ����܂��B�f�t�H���g�ł́A%c FORMAT �����񂪎g���܂��BSSCANF �֐�
% ���g���ăf�o�C�X����ǂݍ��񂾃f�[�^���t�H�[�}�b�g���܂��B
%
% FORMAT �́AC ����ϊ��q���܂ޕ�����ł��B�ϊ��ݒ�q�́A�L�����N�^ % �A
% �I�v�V�����t���O�A�I�v�V�������A���x�̃t�B�[���h�A�I�v�V�����T�u�^�C�v
% �ݒ�q�A�ϊ��L�����N�^ d, i, o, u, x, X, f, e, E, g, G, c, s ���܂݂�
% ���B���ׂĂ̏ڍׂɂ��ẮASPRINTF �t�@�C���� I/O �t�H�[�}�b�g�w��A
% �܂��� C �}�j���A�����Q�Ƃ��Ă��������B
%
% A=FSCANF(OBJ,'FORMAT',SIZE) �́Aserial port �I�u�W�F�N�g OBJ �ɐڑ�
% ���ꂽ�f�o�C�X����w�肳�ꂽ�l�̐� SIZE ��ǂݍ��݂܂��B
%
% FSCANF �́A���̎����̓��̈��������ƃu���b�N����܂��B:
%     1. Terminator �v���p�e�B�Ŏw�肳�ꂽ�I�[�q���󂯎��
%     2. Timeout �v���p�e�B�Ŏw�肳�ꂽ���Ԑ؂ꂪ��������
%     3. SIZE �̒l���󂯎��ꂽ
%
% SIZE �̗��p�\�ȃI�v�V�����͈ȉ��̒ʂ�ł��B:
%
%    N      ��x�N�g�����ŁA�ō��� N �l�܂œǂݍ���
%    [M,N]  ��̏��ɁAM �s N ��̍s��𖞂����悤�ɍō� M*N �v�f�܂�
%           �f�[�^��ǂݍ���
%
% SIZE ��INF �ɐݒ肷�邱�Ƃ͂ł��܂���BSIZE ���AOBJ �� InputBufferSize 
% �v���p�e�B�l���傫���ꍇ�A�G���[�������܂��BSIZE �́A�l�Őݒ肵�A
% ����AInputBufferSize �́A�o�C�g�Őݒ肷�邱�Ƃɒ��ӂ��Ă��������B
%
% �s�� A ���A�L�����N�^�ϊ��݂̂̎g�p�̌��ʂŁASIZE ���A[M,N]�̌^������
% ���Ȃ��ꍇ�A�s�x�N�g�����o�͂���܂��B
%
% [A,COUNT]=FSCANF(OBJ,...) �́A�ǂݍ��񂾒l�̐��� COUNT �ɏo�͂��܂��B
%
% [A,COUNT,MSG]=FSCANF(OBJ,...) �́AFSCANF �����S�ɂ��܂��@�\���Ȃ��ꍇ�A
% ���b�Z�[�W MSG ���o�͂��܂��BMSG ���w�肳��Ă��Ȃ��ꍇ�A���[�j���O��
% �R�}���h���C���ɕ\������܂��B
%
% OBJ �� ValuesReceived �v���p�e�B�́A�f�o�C�X����ǂݍ��܂��
% �l�̐��ōX�V����܂��B
% 
% OBJ �� RecordStatus �v���p�e�B�́A�֐� RECORD �� on �ɐݒ肳��Ă���
% �ꍇ�A�f�[�^�́AOBJ �� RecordName �v���p�e�B�l�Ɏw�肳�ꂽ�t�@�C����
% �ɋL�^����܂��B
%    
% ���:
%       s = serial('COM1');
%       fopen(s);
%       fprintf(s, '*IDN?');
%       idn = fscanf(s);
%       fclose(s);
%       delete(s);
%
% �Q�l : SERIAL/FOPEN, SERIAL/FREAD, SERIAL/RECORD, STRREAD, SSCANF.


%    Copyright 1999-2004 The MathWorks, Inc. 
