% FREAD   �f�o�C�X����o�C�i���f�[�^��ǂݍ���
% 
% A=FREAD(OBJ,SIZE) �́Aserial port �I�u�W�F�N�g OBJ �ɐڑ����Ă���f�o�C�X
% ����A���Ȃ��Ƃ��w�肳�ꂽ�l�̐� SIZE ��ǂݍ��݁AA �ɏo�͂��܂��B
%
% FREAD �́A���̎����̓��̈��������܂ŁA�u���b�N���܂��B:
%     1. SIZE �̒l���󂯎��ꂽ
%     2. Timeout �v���p�e�B�Ŏw�肳�ꂽ���Ԑ؂ꂪ��������
%
% serial port �I�u�W�F�N�g OBJ �́A�C�ӂ̃f�[�^���f�o�C�X����ǂݍ��܂��
% �O�� FOPEN �֐����g���ăf�o�C�X�ɐڑ����Ă��Ȃ���΂Ȃ�܂���B���̑���
% �ꍇ�́A�G���[���o�͂���܂��B�ڑ����ꂽ serial port �I�u�W�F�N�g�́A
% open �� Status �v���p�e�B�l�������Ă��܂��B
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
% A=FREAD(OBJ,SIZE,'PRECISION') �́A�w�肵�����x PRECISION �Ńo�C�i��
% �f�[�^��ǂݍ��݂܂��B���x�Ɋւ�������́A�e�l�̃r�b�g�����R���g���[��
% ���A�����̃r�b�g���L�����N�^�A�����A���������_�̂����ꂩ�Ƃ��ĉ���
% ���܂��B�T�|�[�g����Ă��� PRECISION ������́A�ȉ��̂Œ�`����܂��B
% �f�t�H���g�́A'uchar' �� PRECISION ���g���܂��B�f�t�H���g�ŁA���l�́A
% �{���x�z��ŏo�͂���܂��B
%   
%    MATLAB           �L�q
%    'uchar'          �����Ȃ��L�����N�^   8 bits.
%    'schar'          �����t���L�����N�^   8 bits.
%    'int8'           ����                 8 bits.
%    'int16'          ����                 16 bits.
%    'int32'          ����                 32 bits.
%    'uint8'          �����Ȃ�����         8 bits.
%    'uint16'         �����Ȃ�����         16 bits.
%    'uint32'         �����Ȃ�����         32 bits.
%    'single'         ���������_           32 bits.
%    'float32'        ���������_           32 bits.
%    'double'         ���������_           64 bits.
%    'float64'        ���������_           64 bits.
%    'char'           �L�����N�^           8 bits 
%                                          (�����t���A�܂��́A�����Ȃ�)
%    'short'          ����                 16 bits.
%    'int'            ����                 32 bits.
%    'long'           ����                 32 �܂��� 64 bits.
%    'ushort'         �����Ȃ�����         16 bits.
%    'uint'           �����Ȃ�����         32 bits.
%    'ulong'          �����Ȃ�����         32 bits �܂��� 64 bits.
%    'float'          ���������_           32 bits.
%
% [A,COUNT]=FREAD(OBJ,...) �́A�ǂݍ��񂾒l�̐��� COUNT �ɏo�͂��܂��B
%
% [A,COUNT,MSG]=FREAD(OBJ,...) �́AFREAD �����S�ɂ��܂��@�\���Ȃ��ꍇ�A
% ���b�Z�[�W MSG ���o�͂��܂��BMSG ���w�肳��Ă��Ȃ��ꍇ�A���[�j���O��
% �R�}���h���C���ɕ\������܂��B
%
% �f�o�C�X�̃o�C�g���́AOBJ �� ByteOrder �v���p�e�B�Ŏw�肷�邱�Ƃ�
% �ł��܂��B
%
% OBJ �� ValuesReceived �v���p�e�B�́A�f�o�C�X����ǂݍ��܂��
% �l�̐��ōX�V����܂��B
% 
% OBJ �� RecordStatus �v���p�e�B�́A�֐� RECORD �� on �ɐݒ肳��Ă���
% �ꍇ�A�f�[�^�́AOBJ �� RecordName �v���p�e�B�l�Ɏw�肳�ꂽ�t�@�C����
% �ɋL�^����܂��B
%
% ���:
%      s = serial('COM1');
%      fopen(s);
%      fprintf(s, 'Curve?');
%      data = fread(s, 512);
%      fclose(s);
%
% �Q�l : SERIAL/FOPEN, SERIAL/FSCANF, SERIAL/FGETS, SERIAL/FGETL,
%        SERIAL/RECORD.
%


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
