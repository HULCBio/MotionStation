%SFPRINT Stateflow�_�C�A�O�����̈��
%   SFPRINT�́A�J�����g��Stateflow�_�C�A�O�����̕\������Ă���͈͂������
%   �܂��B
%
%   SFPRINT(objects, format, outputOption, printEntireChart)�́A�]��
%   ���ꂽ�I�u�W�F�N�g�̂����ꂩ�̃`���[�g���t�@�C���܂��̓f�t�H���g�v�����^
%   �Ɉ�����܂��B
%
%   �I�u�W�F�N�g�p�����[�^�́AStateflow�`���[�g�ASimulink���f���A�V�X�e��
%   �܂��̓u���b�N�A�܂��͂�����g�ݍ��킹������(�Z���z��܂��̓n���h����
%   �x�N�g��)�̖��O���邢��id(�n���h��)�ɂȂ�܂��B
%
%   formats�̈ꗗ:
%        'default'
%        'ps'         �|�X�g�X�N���v�g�t�@�C���̐���
%        'psc'        �J���[�|�X�g�X�N���v�g�t�@�C���̐���
%        'eps'        EPS(encapsulated postscript)�t�@�C���̐���
%        'epsc'       �J���[EPS(encapsulated postscript)�t�@�C���̐���
%        'tif'        TIFF�t�@�C���̐���
%        'jpg'        JPEG�t�@�C���̐���
%        'png'        PNG�t�@�C���̐���
%        'meta'       Stateflow�C���[�W�����^�t�@�C���Ƃ��ăN���b�v�{�[�h
%			  �ɕۑ�(PC�݂̂ŉ�!)
%        'bitmap'     Stateflow�C���[�W���r�b�g�}�b�v�t�@�C���Ƃ��ăN���b�v
%			  �{�[�h�ɕۑ�(PC�݂̂ŉ�!)
%
%        �t�H�[�}�b�g�p�����[�^�����݂��Ȃ��ꍇ(sfprint��1�̈����ŃR�[��
%        ���ꂽ�ꍇ)�́A�t�H�[�}�b�g�̓f�t�H���g��'ps'���g���A�o�͂̓f�t�H
%        ���g�v�����^�ɑ����܂��B
%
%   �\��outputOptions:
%        �t�@�C�����̕�����		  �������ރt�@�C�����w�肵�܂�(�������
%					  ���̂���������ꍇ�A�t�@�C���͏㏑��
%					  ����܂�)
%        'promptForFile' �L�[���[�h �_�C�A���O���g���Đq�˂���t�@�C����
%        'printer' �L�[���[�h       �o�͂́A�f�t�H���g�̃v�����^�ɑ����܂�
%                                   ('default', 'ps' ,'eps' �t�H�[�}�b�g
%					  �̂����ꂩ���g�p��)
%        'file'          �L�[���[�h  �o�͂́A�f�t�H���g�̃t�@�C���ɑ����܂�
%                                   <�I�u�W�F�N�g�̃p�X>.<�f�o�C�X�̊g���q>
%        'clipboard',    �L�[���[�h�@�o�͂́A�N���b�v�{�[�h�ɃR�s�[����܂�
%
%        outputOption�p�����[�^�����݂��Ȃ����A���邢�͋�̏ꍇ�́A�J�����g
%	  �f�B���N�g���̃f�t�H���g�t�@�C����(�`���[�g��)���g���܂��B
%
%   printEntireChart�p�����[�^�̓I�v�V�����ł��B2�̎g�p�\�Ȓl������܂��B
%        1 (�f�t�H���g)   �S�̂̃`���[�g�����
%        0             �`���[�g�̒��ŃJ�����g�ɉ�������Ă�����̂����
%
%   ���:
%      sfprint(id, 'tif', ...
%                  'myFilename'); % �`���[�g/�T�u�`���[�g(id)��tiff�t�@�C
%					 % ���Ɉ��
%
%      sfprint( gcs )              % �J�����g�V�X�e���̂��ׂẴ`���[�g�����
%
%      sfprint( gcb, 'jpg', ...    % �J�����g�u���b�N(Stateflow�u���b�N�̏ꍇ
%             'promptForFile')     % ��JPEG�t�H�[�}�b�g��(�_�C�A���O�Ŏw��
%					  % �������O�Ńt�@�C���Ɉ��
%
%      sfprint( gcs, 'tif', ...    % �f�t�H���g�t�@�C�������g���āA
%             'file', 1);          % �J�����g�V�X�e�� ���̂��ׂĂ�Stateflow
%					  % �`���[�g������B�S�̂̃`���[�g������B
%
%   �Q�l�@STATEFLOW, SFNEW, SFSAVE, SFEXIT, SFHELP.

%   Copyright (c) 1995-2002 The MathWorks, Inc.
