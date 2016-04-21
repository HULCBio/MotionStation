% FWRITE   �o�C�i���f�[�^���f�o�C�X�ɏ�������
%
% FWRITE(OBJ, A) �́A�f�[�^ A �� serial port �I�u�W�F�N�g OBJ �ɐڑ�
% ���Ă���f�o�C�X�ɏ������݂܂��B
%
% serial port �I�u�W�F�N�g�́A�C�ӂ̃f�[�^���f�o�C�X�ɏ������܂��O��
% �֐� FOPEN ���g���ăf�o�C�X�ɐڑ�����Ă��Ȃ���΂Ȃ�܂���B���̏ꍇ�A
% �G���[���o�͂���܂��B�ڑ����ꂽ serial port �I�u�W�F�N�g�́Aopen ��
% Status �v���p�e�B�������܂��B
%
% FWRITE(OBJ,A,'PRECISION') �́A�w�肵�����x PRECISION �Ńo�C�i���f�[�^
% ��MATLAB �l�ɕϊ����ď������݂܂��B�T�|�[�g����� PRECISION ������́A
% �ȉ��Œ�`����܂��B�f�t�H���g�́A'uchar' �� PRECISION ���g���܂��B
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
% FWRITE(OBJ, A, 'MODE')
% FWRITE(OBJ, A, 'PRECISION', 'MODE') �́AMODE ���A'async' �̏ꍇ�A
% �f�o�C�X�ɔ񓯊��Ńf�[�^���������݁AMODE �� 'sync' �̏ꍇ�A������
% �Ƃ��ăf�o�C�X�Ƀf�[�^���������݂܂��B�f�t�H���g�ŁA�f�[�^�́A'sync'
% MODE �ŏ������܂�A���̂��Ƃ́A�w�肵���f�[�^���A�f�o�C�X�ɏ������
% ������A�^�C���A�E�g�������Ă�����A�R���g���[����MATLAB �ɖ߂邱�Ƃ�
% �Ӗ����܂��B'async' MODE ���g�p�����ꍇ�A�R���g���[���� FWRITE  
% �R�}���h�����s���ꂽ���ƁA�����ɁAMATLAB �ɖ߂�܂��B
%
% �f�o�C�X�̃o�C�g���́AOBJ �� ByteOrder �v���p�e�B�Ŏw�肷�邱�Ƃ�
% �ł��܂��B
%
% OBJ �� ValuesSent �v���p�e�B�́A�f�o�C�X�ɋL�q�����l�̐��ōX�V
% ����܂��B
%
% OBJ �� RecordStatus �v���p�e�B���ARECORD �R�}���h�ɂ�� on ��
% �ݒ肳��Ă���ꍇ�A�f�o�C�X�ɋL�q���ꂽ�f�[�^�́AOBJ �� RecordName 
% �v���p�e�B�l�Ɏw�肳�ꂽ�t�@�C�����ɋL�^����܂��B
%
% ���:
%      s = serial('COM1');
%      fopen(s);
%      fwrite(s, [0 5 5 0 5 5 0]);
%      fclose(s);
%
% �Q�l : SERIAL/FOPEN, SERIAL/FPRINTF, SERIAL/RECORD.


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
