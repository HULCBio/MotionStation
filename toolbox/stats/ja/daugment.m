% DAUGMENT   D-�œK�v��̊g��
%
% [SETTINGS, X] = DAUGMENT(STARTDES,NRUNS,MODEL) �́A���W����D-�œK�v��
% �A���S���Y�����g�p���āA�����v��Ɏ��sNRUNS��t�����܂��BSTARTDES �́A
% �I���W�i���̌v��̗v���ݒ�̍s��ł��B�o�͂́A�v���ݒ�s�� SETTINGS ��
% ���f���� �̊֘A����s�� X (�݌v�s��ƌĂ΂�邱�Ƃ�����)�ł��BMODEL �́A
% ��A���f���̎������R���g���[������I�v�V�����̈����ł��B�f�t�H���g�ł́A
% DAUGMENT �́A�萔���������`���@���f���ɑ΂���v��s����o�͂��܂��B 
% MODEL �́A���̕�����̂����ꂩ�ɂȂ�܂��B:
%
%     'linear'        �萔�A���`��������(�f�t�H���g)
%     'interaction'   �萔�A���`�A�N���X�ς̍�������
%     'quadratic'     ���ݍ��ɁA��捀��������
%     'purequadratic' �萔�A���`�A��捀������
%
% MODEL�́A�֐� X2FX �Ŏg�p�ł���v�f�\������Ȃ�s��̌^�ł��ݒ�ł��܂��B
%
% [SETTINGS, X] = DAUGMENT(...,'PARAM1',VALUE1,'PARAM2',VALUE2,...)
% �́A�p�����[�^/�l�̑g���g���āA�v��쐬���R���g���[�����܂��B
% ���p�\�ȃp�����[�^�́A���̂悤�ɂȂ�܂��B:
%
%      �p�����[�^   �l
%      'display'    �J��Ԃ��J�E���^ �̕\�����R���g���[�����邽�߂�
%                   'on'�A���邢�́A'off'�̂����ꂩ�ƂȂ�܂��B
%                   (�f�t�H���g = 'on').
%      'init'       �s NRUNS�����s��Ƃ��Ă̏����̌v��
%                   (�f�t�H���g�́A�����_���ɑI�����ꂽ�_�W���ł�)�B
%      'maxiter'    �J��Ԃ��̍ő��(�f�t�H���g = 10).
%
% �Q�l : CORDEXCH, X2FX.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:11:27 $
