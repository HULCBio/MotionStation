%HDF5READ HDF5 �t�@�C������f�[�^��ǂݍ��݂܂�
%
% HDF5READ �́AHDF5 �t�@�C���̃f�[�^�Z�b�g����f�[�^��ǂݍ��݂܂��B
% �f�[�^�Z�b�g�̖��O�����m�̏ꍇ�AHDF5READ �́A�t�@�C���̃f�[�^����
% �����܂��B�����łȂ��ꍇ�A�t�@�C���̓��e���L�q����\���̂��擾����
% ���߂ɁAHDF5INFO ���g�p���Ă��������BHDF5INFO �ɂ��o�͂����\����
% �̃t�B�[���h�́A�t�@�C���Ɋ܂܂��f�[�^�Z�b�g���L�q����\���̂ł��B
% �f�[�^�Z�b�g���L�q����\���̂́A���o����AHDF5READ �ɒ��ړn����
% �܂��B�����̃I�v�V�����ɂ��āA�ȉ��ɏڍׂ��q�ׂ܂��B
%
% DATA = HDF5READ(FILENAME,DATASETNAME) �́A�ϐ� DATA �ɁADATASETNAME
% �Ƃ������O�̃f�[�^�ɂ��āA�t�@�C�� FILENAME ����A���ׂẴf�[�^��
% �o�͂��܂��B
%
% ATTR = HDF5READ(FILENAME,ATTRIBUTENAME) �́A�ϐ� ATTR �ɁA
% ATTRIBUTENAME �Ƃ������O�̑����ɂ��āA�t�@�C�� FILENAME ����A���ׂ�
% �̃f�[�^���o�͂��܂��B
%
% [DATA, ATTR] = HDF5READ(..., 'ReadAttributes', BOOL) �́A�f�[�^�Z�b�g
% �̃f�[�^�����A���̃f�[�^�Z�b�g�Ɋ܂܂��֘A���鑮�����ƂƂ���
% �o�͂��܂��B�f�t�H���g�ł́ABOOL �́Afalse �ł��B
%
% DATA = HDF5READ(HINFO) �́A�ϐ� DATA �ɁAHINFO �ɂ��L�q���������
% �f�[�^�Z�b�g�ɂ��āA�t�@�C������A���ׂẴf�[�^���o�͂��܂��B
% HINFO �́AHDFINFO �̏o�͍\���̂�����o�����\���̂ł�(���Q��)�B
%   
% ���:
%
%   % HDF5INFO �\���̂ɂ��ƂÂ��f�[�^�Z�b�g�̓ǂݍ���
%   info = hdf5info('example.h5');
%   dset = hdf5read(info.GroupHierarchy.Groups(2).Datasets(1));
%
% �Q�l HDF5INFO, HDF5WRITE, HDF5COPYRIGHT.TXT.

%   binky
%   Copyright 1984-2002 The MathWorks, Inc. 
