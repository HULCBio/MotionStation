% FPRINTF   �f�o�C�X�Ƀe�L�X�g����������
%
% FPRINTF(OBJ,'CMD') �́Aserial port �I�u�W�F�N�g OBJ �ɐڑ�����Ă���
% �f�o�C�X�ɕ����� CMD ���������݂܂��BOBJ �́A1�s1��� serial port 
% �I�u�W�F�N�g�łȂ���΂Ȃ�܂���B
%
% serial port �I�u�W�F�N�g�́A�C�ӂ̃f�[�^���f�o�C�X�ɏ������܂��O��
% �֐� FOPEN ���g���ăf�o�C�X�ɐڑ�����Ă��Ȃ���΂Ȃ�܂���B���̏ꍇ�A
% �G���[���o�͂���܂��B�ڑ����ꂽ serial port �I�u�W�F�N�g�́Aopen ��
% Status �v���p�e�B�������܂��B
%
% FPRINTF(OBJ,'FORMAT','CMD') �́Aserial port �I�u�W�F�N�g OBJ �ɐڑ�
% ���ꂽ�f�o�C�X�ɁA�t�H�[�}�b�g FORMAT ���g���āA������ CMD ����������
% �܂��B�f�t�H���g�ŁA%s\n �� FORMAT �����񂪎g�p����܂��BSPRINTF �֐�
% �́A�@��ɏ������܂ꂽ�t�H�[�}�b�g�f�[�^���g�p���܂��B
% 
% CMD ���� \n �̏o���̓x�ɁAOBJ �� Terminator �v���p�e�B�l���u������
% ���܂��B�f�t�H���g FORMAT %s\n ���g���ꍇ�A�f�o�C�X�ɋL�q���ꂽ
% ���ׂẴR�}���h���ATerminator �l���Ō�ɂ��܂��B
%
% FORMAT �́AC ����ϊ��q���܂ޕ�����ł��B�ϊ��ݒ�q�́A�L�����N�^ % �A
% �I�v�V�����t���O�A�I�v�V�������A���x�̃t�B�[���h�A�I�v�V�����T�u�^�C�v
% �ݒ�q�A�ϊ��L�����N�^ d, i, o, u, x, X, f, e, E, g, G, c, s ���܂݂�
% ���B���ׂĂ̏ڍׂɂ��ẮASPRINTF �t�@�C���� I/O �t�H�[�}�b�g�w��A
% �܂��� C �}�j���A�����Q�Ƃ��Ă��������B
%
% FPRINTF(OBJ, 'CMD', 'MODE')
% FPRINTF(OBJ, 'FORMAT', 'CMD', 'MODE') �́AMODE ���A'async' �̏ꍇ�A
% �f�o�C�X�ɔ񓯊��Ńf�[�^���������݁AMODE �� 'sync' �̏ꍇ�A������
% �Ƃ��ăf�o�C�X�Ƀf�[�^���������݂܂��B�f�t�H���g�ŁA�f�[�^�́A'sync'
% MODE �ŏ������܂�A���̂��Ƃ́A�w�肵���f�[�^���A�f�o�C�X�ɏ������
% ������A�^�C���A�E�g�������Ă�����A�R���g���[����MATLAB �ɖ߂邱�Ƃ�
% �Ӗ����܂��B'async' MODE ���g�p�����ꍇ�A�R���g���[���� FPRINTF 
% �R�}���h�����s���ꂽ���ƁA�����ɁAMATLAB �ɖ߂�܂��B
%
% OBJ �� TransferStatus �v���p�e�B�́A�񓯊��������݂��i�s�����ۂ���
% �����܂��B
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
%      fprintf(s, 'Freq 2000');
%      fclose(s);
%      delete(s);
%
% �Q�l : SERIAL/FOPEN, SERIAL/FWRITE, SERIAL/STOPASYNC, SERIAL/RECORD,
%        SPRINTF.


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
