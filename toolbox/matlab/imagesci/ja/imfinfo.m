% IMFINFO   �O���t�B�b�N�X�t�@�C���Ɋւ�����
% 
% INFO = IMFINFO(FILENAME,FMT)�́A�O���t�B�b�N�X�t�@�C�����̃C���[�W��
% �ւ�������܂ރt�B�[���h�����\���̂��o�͂��܂��BFILENAME�́A�O��
% �t�B�b�N�X�t�@�C�������w�肷�镶����ŁAFMT�̓t�@�C���̏������w�肷��
% ������ł��B�t�@�C���́A�J�����g�f�B���N�g���܂���MATLAB�p�X��̃f�B
% ���N�g���ɂȂ���΂Ȃ�܂���BIMFINFO��FILENAME�Ƃ����t�@�C��������
% �����Ȃ��ꍇ�́AFILENAME.FMT��T���܂��B
% 
% FMT �̎�蓾��l�́AIMFORMATS �R�}���h�ɂ���ăA�N�Z�X�����t�@�C��
% �`���̓o�^�œ����܂��B
%
% FILENAME���A1�ȏ�̃C���[�W���܂�TIFF, HDF, ICO, CUR�t�@�C���̏ꍇ�A
% INFO�́A�t�@�C�����̊e�C���[�W�ɑ΂���1�v�f�����\���̔z��ł��B
% ���Ƃ��΁AINFO(3)�́A�t�@�C����3�Ԗڂ̃C���[�W�̏����܂݂܂��B
%
% INFO = IMFINFO(FILENAME) �́A���̓��e����t�@�C���̏����𐄑����܂��B
%
% INFO = IMFINFO(URL,...) �́A�C���^�[�l�b�g URL ����C���[�W��ǂݍ�
% �݂܂��BURL �́A�v���g�R���̃^�C�v (�Ⴆ�� "http://") ���܂܂Ȃ����
% �Ȃ�܂���B
%
% INFO ���̃t�B�[���h�́A�X�̃t�@�C���Ƃ��̏����Ɉˑ����܂��B�������A
% �ŏ���9�̃t�B�[���h�͏�ɓ����ł��B�����̋��ʂ̃t�B�[���h���ȉ�
% �Ɏ����܂��B:
%
% Filename       �t�@�C�������܂ޕ�����B
%
% FileModDate    �t�@�C���̏C�����t���܂ޕ�����B
%
% FileSize       �o�C�g�P�ʂŃt�@�C���̃T�C�Y�����������B
%
% Format         FMT�ɂ��w�肳���t�@�C���������܂ޕ�����B���
%                �ȏ�̉\�Ȋg���q���g��������(�Ⴆ�΁AJPEG��TIFF
%                �t�@�C��)�ɑ΂��ẮA�o�^���̍ŏ��̏ȗ��������o�͂�
%                �܂��B
%
% FormatVersion  �t�@�C�������̃o�[�W�������w�肷�镶����܂��͐��l�B
%
% Width          �s�N�Z���P�ʂŃC���[�W�̕���\�킷�����B
%
% Height         �s�N�Z���P�ʂŃC���[�W�̍�����\�킷�����B
%
% BitDepth       �s�N�Z��������̃r�b�g�������������B
%
% ColorType      �C���[�W�̃^�C�v������������B�g�D���[�J���[(RGB)
%                �C���[�W�ɑ΂��Ă� 'truecolor'�A�O���C�X�P�[�����x
%                �C���[�W�ɑ΂��Ă� 'grayscale'�A�C���f�b�N�X�t��
%                �C���[�W�ɑ΂��Ă� 'indexed' �ł��B
%   
% �Q�l�FIMREAD, IMWRITE, IMFORMATS.


%   Steven L. Eddins, June 1996
%   Copyright 1984-2002 The MathWorks, Inc.
