% CORDEXCH   D-�œK�v�� (���W�����A���S���Y��)
%
% [SETTINGS, X] = CORDEXCH(NFACTORS,NRUNS,MODEL) �́A�v��NFACTORS�ɑ΂��āA
% NRUNS������D-�œK�v����쐬���܂��BSETTINGS �́A�v��̂��߂̗v���ݒ�
% �s��ł���AX �́A(�v��s��ƌĂ΂�邱�Ƃ�����)���̒l�̍s��ł��B
% MODEL �́A��A���f���̎������R���g���[������I�v�V�����̈����ł��B
% MODEL �́A���̕�����̂����ꂩ�ɂȂ�܂��B:
%
%     'linear'        �萔�A���`��������(�f�t�H���g)
%     'interaction'   �萔�A���`�A�N���X�ς̍�������
%     'quadratic'     ���ݍ��ɁA��捀��������
%     'purequadratic' �萔�A���`�A��捀������
%
% MODEL �́A�֐� X2FX �Ŏg�p�ł���v�f�\������Ȃ�s��̌^�ł��ݒ�ł��܂��B
%
% [SETTINGS, X] = CORDEXCH(...,'PARAM1',VALUE1,'PARAM2',VALUE2,...)�́A
% �p�����[�^/�l�̑g���g���āA�v��쐬�̃R���g���[�������܂��B
% �g�p�\�ȃp�����[�^�́A���̂悤�ɂȂ�܂��B:
%
%      �p�����[�^   �l
%      'display'    �J��Ԃ��J�E���^(�f�t�H���g = 'on')�̕\�����R���g���[��
%                   ���邽�߂ɁA'on' �A���邢�́A'off'�̂����ꂩ�ɂȂ�܂��B
%      'init'       NRUNS�~NFACTORS �s��Ƃ��Ă̏����v��
%                   (�f�t�H���g�́A�����_���ɑI�����ꂽ�_�W���ł�)�B
%      'maxiter'    �J��Ԃ��̍ő�� (�f�t�H���g = 10)�B
%
% �֐�CORDEXCH �́A���W�����A���S���Y�����g�p���āA D-�œK�v����s���܂��B
% ����́A�o���_�̌v����쐬���A���ꂩ��A���̌v����g�p���Đ��肳���W��
% �̕ϓ������炷���߂ɁA�e�v��_�̊e���W���������邱�Ƃɂ��A�J��Ԃ��܂��B
%
% �Q�l : ROWEXCH, DAUGMENT, DCOVARY, X2FX.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:11:18 $ 
