% SERIAL   serial port �I�u�W�F�N�g�̍쐬
%
% S = SERIAL('PORT') �́A�|�[�g PORT �Ɋ֘A���� serial port �I�u�W�F�N�g��
% �쐬���܂��BPORT ���A���݂��ĂȂ�������A�g�p���̏ꍇ�Aserial port �I�u
% �W�F�N�g���f�o�C�X�ɐڑ����邱�Ƃ͂ł��܂���B
%
% �f�o�C�X�Ƃ̒ʐM���s�����߂ɁA�I�u�W�F�N�g�́A�֐� FOPEN ���g���āA
% serial port �ɐڑ�����K�v������܂��B
%
% serial port �I�u�W�F�N�g���쐬�����ƁA�I�u�W�F�N�g�� Status �v���p
% �e�B���N���[�Y���܂��B�I�u�W�F�N�g���֐� FOPEN ���g���āAserial port 
% �ɐڑ������ƁAStatus �v���p�e�B�́Aopen �ɐݒ肳��܂��B��� 
% serial port �I�u�W�F�N�g�́A��x�ɁA��� serial port �݂̂ɐڑ�����
% ���Ƃ��ł��܂��B
%
% S = SERIAL('PORT','P1',V1,'P2',V2,...) �́A�|�[�g PORT �Ɋ֘A���� 
% serial port �I�u�W�F�N�g���쐬���܂��B�����āA���̒��ɂ́A�w�肵��
% �v���p�e�B�l���܂�ł��܂��B�s�K�؂ȃv���p�e�B���A�܂��́A�v���p�e�B�l
% ���w�肳��Ă���ꍇ�A�I�u�W�F�N�g�͍쐬����܂���B
%
% �v���p�e�B���ƒl�̑g�́A�֐� SET �ŃT�|�[�g����Ă���C�ӂ̃t�H�[�}�b�g
% �ŋL�q�ł��邱�Ƃɒ��ӂ��Ă��������B���Ƃ��΁A�p�����[�^-�l�̕������
% �g�A�\���́A�Z���z�񓙂ł��B
%
% ���:
%       % serial port �I�u�W�F�N�̍쐬:
%         s1 = serial('COM1');
%         s2 = serial('COM2', 'BaudRate', 1200);
%
%       % serial port �I�u�W�F�N�g�� Serial port �ɐڑ�:
%         fopen(s1)
%         fopen(s2)	
%
%       % �f�o�C�X�̓ǂݍ���
%         fprintf(s1, '*IDN?');
%         idn = fscanf(s1);
%
%       % serial port ���� serial port �I�u�W�F�N�g��ؒf
%         fclose(s1); 
%         fclose(s2);
%
% �Q�l : SERIAL/FOPEN.


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
