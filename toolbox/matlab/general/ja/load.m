% LOAD   �f�B�X�N���烏�[�N�X�y�[�X�ϐ������[�h
% 
% LOAD FILENAME �́A�t���p�X���A�܂��́AMATLAB�����p�X����^���āA�t�@
% �C�����炷�ׂĂ̕ϐ���ǂݍ��݂܂�(PARTIALPATH ���Q��)�BFILENAME ��
% �g���q���Ȃ��ꍇ�ALOAD �́AFILENAME �� FILENAME.mat ��T���A�����
% �o�C�i����"MAT-�t�@�C��"�Ƃ��Ď�舵���܂��BFILENAME ���A.mat �ȊO�̊g
% ���q�������Ă���ꍇ�A����� ASCII �Ƃ��Ď�舵���܂��B
%
% LOAD ���g�ł́A'matlab.mat'�Ɩ��t�����o�C�i��MAT-�t�@�C���𗘗p���܂��B
% 'matlab.mat' ��������Ȃ��ꍇ�́A�G���[�ɂȂ�܂��B
%
% LOAD FILENAME X �́AX �݂̂����[�h���܂��B
% LOAD FILENAME X Y Z ... �́A�w�肵���ϐ������[�h���܂��B����p�^�[����
% ��v����ϐ������[�h���邽�߂ɁA���C���h�J�[�h'*'���g�p�ł��܂�
% (MAT-�t�@�C���̂�)�B
%
% LOAD FILENAME -REGEXP PAT1 PAT2 �́A���K�\�����g�p���Ďw�肵���p�^�[����
% ��v���邷�ׂĂ̕ϐ������[�h���邽�߂Ɏg�p���邱�Ƃ��ł��܂��B���K�\����
% �g�p����ڍׂ́A�R�}���h�v�����v�g�� "doc regexp" �Ɠ��͂��Ă��������B
%
% LOAD -ASCII FILENAME �܂��� LOAD -MAT FILENAME �́A�t�@�C���̊g��
% �q�Ɋւ�炸�A�t�@�C����ASCII�t�@�C���܂���MAT�t�@�C���Ƃ��Ď�舵��
% �܂��B-ASCII �̏ꍇ�A�t�@�C�������l�e�L�X�g�łȂ��ꍇ�A�G���[�ɂȂ�܂��B
% -MAT �̏ꍇ�ASAVE -MAT �ō쐬����MAT�t�@�C���łȂ��ꍇ�A�G���[�ɂȂ�
% �܂��B
% 
% FILENAME �� MAT�t�@�C���̏ꍇ�AFILENAME ����v�����ꂽ�ϐ������[�N�X
% �y�[�X���ɍ쐬����܂��BFILENAME ��MAT�t�@�C���łȂ��ꍇ�A�{���x�z��
% ��FILENAME ���x�[�X�ɂ������O�ō쐬����܂��BFILENAME �ɃA���_�[�X�R
% �A�␔��������ꍇ�́AX �Œu�������܂��BFILENAME ���̃A���t�@�x�b�g
% �łȂ��L�����N�^�́A�A���_�[�X�R�A�ƒu�������܂��B
% 
% S = LOAD(...) �́AFILENAME �̓��e��ϐ� S �ɏo�͂��܂��BFILENAME �� 
% MAT�t�@�C���̏ꍇ�AS �͓ǂݍ��܂ꂽ�ϐ��ƈ�v����t�B�[���h�����\��
% �̂ɂȂ�܂��BFILENAME ���AASCII�t�@�C���̏ꍇ�AS �͔{���x�z��ɂ�
% ��܂��B
% 
% �t�@�C������������Ƃ��Ċi�[����Ă���A���邢�͏o�͈������K�v�ȏꍇ�A
% �܂��́AFILENAME ���X�y�[�X���܂�ł���ꍇ�́A���Ƃ��΁ALOAD('filen-
% ame') �̂悤�� LOAD �̊֐��`�����g���Ă��������B
%
% �p�^�[���}�b�`���O�̗�:
% load fname a*                % "a" �ł͂��܂�ϐ�������
% load fname -regexp ^b\d{3}$  % "b" �ł͂��܂�A 3 digits
%                              % �������ϐ�������
% load fname -regexp \d        % �C�� digits ���܂ޕϐ�������
%
% �Q�l�F SAVE, WHOS, UILOAD, SPCONVERT, PARTIALPATH, IOFUN, FILEFORMATS.


% Copyright 1984-2002 The MathWorks, Inc.
