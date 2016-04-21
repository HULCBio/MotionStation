% MULTIBANDREAD   �o�C�i���t�@�C������band-interleaved�f�[�^�̓ǂݍ���
%
% X = MULTIBANDREAD(FILENAME,SIZE,PRECISION,
%                  OFFSET,INTERLEAVE,BYTEORDER) 
% �́A�o�C�i���t�@�C�� FILENAME ���� band-sequential (BSQ)�A
% band-interleaved-by-line (BIL)�A�܂���band-interleaved-by-pixel (BIP)
%  �f�[�^��ǂݍ��݂܂��BX �́A1�̃o���h�̂ݓǂݍ��ޏꍇ��2�����ŁA
% ����ȊO��3�����ɂȂ�܂��BX �́A�f�t�H���g�Ŕ{���x�̃f�[�^�^�C�v��
% �z��Ƃ��ďo�͂���܂��B�قȂ�f�[�^�^�C�v�Ƀf�[�^���ʑ����邽�߂ɁA
% PRECISION �������g���Ă��������B
%
% X = MULTIBANDREAD(FILENAME,SIZE,PRECISION,OFFSET,INTERLEAVE,
%                  BYTEORDER,SUBSET,SUBSET,SUBSET)
% �́A�t�@�C�����̃f�[�^�̃T�u�Z�b�g��ǂݍ��݂܂��B�ő��3�̃T�u
% �Z�b�g�̃p�����[�^���Ɨ����čs�A��A�o���h�̎����ɉ����Ďg�p����܂��B
%
% �p�����[�^:
%
%   FILENAME: �ǂݍ��ނ��߂̃t�@�C�������܂ޕ�����
%
%   SIZE: [HEIGHT, WIDTH, N] ��3�v�f�̐����x�N�g���BHEIGHT �͍s�̑����ŁA
%         WIDTH �͊e��̍s�̊e�s�̑����A�܂� N �̓o���h�̑����ł��B
%         ���ׂĂ�ǂݍ��ޏꍇ�A����̓f�[�^�̎����ɂȂ�܂��B
%
%   PRECISION: �ǂݍ��ނ��߂̃f�[�^�̏������w�肷�镶����B�Ⴆ�΁A
%              'uint8'�A'double'�A'integer*4'�ł��B�f�t�H���g�ɂ��A
%              X �͔{���x�̃N���X�̔z��Ƃ��ďo�͂���܂��B�قȂ�N���X
%              �̏�����ݒ肷��ɂ�PRECISION�p�����[�^��p���Ă��������B
%              �Ⴆ�΁A'uint8=>uint8'(�܂���'*uint8') �̐��x�́AUNIT8
%              �z��Ƃ��ăf�[�^���o�͂��܂��B'uint8=>single' �́A���ꂼ��
%              8�r�b�g�s�N�Z���Ƃ��ēǂݍ��݁A�P���x�Ƃ���MATLAB�Ɋi�[
%              ���܂��BPRECISION �̂�芮�S�ȏڍׂɂ��Ă� FREAD ��
%              �w���v���Q�Ƃ��Ă��������B
%
%   OFFSET: �t�@�C�����̍ŏ��̃f�[�^�v�f�̃[������Ƃ����ʒu�B
%           ���̒l�̓t�@�C���̊J�n����f�[�^�̐擪�ƂȂ�ʒu�܂ł�
%           �o�C�g���������܂��B
%
%   INTERLEAVE: �i�[���ꂽ�f�[�^�̏����B����� Band-Seqential�A
%               Band-Interleaved-by-Line�ABand-Interleaved-by-Pixel ��
%               �΂��Ă��ꂼ�� 'bsq'�A'bil'�A�܂��� 'bip' �̂ǂ��炩��
%               �Ȃ�܂��B
%
%   BYTEORDER: �i�[���ꂽ�f�[�^���̃o�C�g����(�}�V���t�H�[�}�b�g)�B
%              ����� little-endian �ɑ΂��� 'ieee-le' ���A�܂���
%              big-endian �ɑ΂��� 'ieee-be' �ɂȂ�܂��BFOPEN �� help
%              �ɋL�q���ꂽ���̃}�V���t�H�[�}�b�g�́ABYTEORDER �ɑ΂���
%              ���L���Ȓl�ł��B
%
%   SUBSET: (�I�v�V����) {DIM,INDEX} �� {DIM,METHOD,INDEX} ���܂ރZ���z��B
%           DIM �́A�Ɨ������T�u�Z�b�g�̎������w�肷�� 'Column'�A'Row'�A
%           'Band' ��3�̕������1�ł��BMETHOD �́A'Direct' �܂��� 
%           'Range' �ł��BMETHOD ���ȗ������ꍇ�A�f�t�H���g�� 'Direct'
%           �ł��B'Direct' �̃T�u�Z�b�g�����g�p����ꍇ�AINDEX �͓Ɨ�
%           �����o���h������ǂݍ��ނ��߂Ɏw�肳���C���f�b�N�X�̃x�N�g��
%           �ł��BMETHOD �� 'Range' �̏ꍇ�AINDEX �͔͈͂ƃX�e�b�v�T�C�Y��
%           �Ɨ����������œǂݍ��ނ��߂Ɏw�肷�� [START, INCREMENT, STOP] 
%           ��2�܂���3�v�f�̃x�N�g���ł��BINDEX ��2�v�f�̏ꍇ�AINCREMENT 
%           ��1�ł���Ɖ��肳��܂��B
%
% ���
% ----
%
%   864�~702�~3�� uint8 �̍s����ɂ��ׂẴf�[�^��ǂݍ��݂܂��B
%          im = multibandread('bipdata.img',...
%                            [864,702,3],'uint8=>uint8',0,'bip','ieee-le');
%
%   3�A4�A6�̃o���h���������ׂĂ̍s�Ɨ��ǂݍ��݂܂��B
%          im = multibandread('bsqdata.img',...
%                            [512,512,6],'uint8',0,'bsq','ieee-le',...
%                            {'Band','Direct',[3 4 6]});
%
%   ���ׂẴo���h�ƍs�Ɨ񂪓Ɨ������T�u�Z�b�g��ǂݍ��݂܂��B
%          im = multibandread('bildata.int',...
%                            [350,400,50],'uint16',0,'bil','ieee-le',...
%                            {'Row','Range',[2 2 350]},...
%                            {'Column','Range',[1 4 350]});
%
% �Q�l : FREAD, FOPEN. 



%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:57:09 $
%   $Revision.1 $  $Date: 2004/04/28 01:57:09 $

