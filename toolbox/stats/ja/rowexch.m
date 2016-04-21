% ROWEXCH   ������D-�œK�v��(�s�����A���S���Y��)
%
% [SETTINGS, X] = ROWEXCH(NFACTORS,NRUNS,MODEL) �́A�v�� NFACTORS �ɑ΂���
% NRUNS ���s������D-�œK�v����쐬���܂��BSETTINGS �́A�v��ɑ΂���v����
% ��̍s��ł���AX �́A���̒l�����s��(�v��s��ƌĂ΂�邱�Ƃ�����)��
% ���BMODEL �́A�I�v�V�����̈����ŁA��A���f���̎������R���g���[�����܂��B
% �f�t�H���g�ł́AROWEXCH �́A�萔���������`���Z���f���ɑ΂���v��s��
% ���o�͂��܂��BMODEL�́A���̕�����̂����ꂩ�ɂȂ�܂��B
%
%     'linear'        �萔�A���`�����܂� (�f�t�H���g)
%     'interaction'   �萔�A���`�A�N���X�ς̍����܂�
%     'quadratic'     ���ݍ�p�ɓ�捀��ǉ�
%     'purequadratic' �萔�A���`�A��捀���܂�
%
% MODEL �́A�֐� X2FX �Ŏg�p�ł���v�f�\������Ȃ�s��̌^�ł��ݒ�ł��܂��B
%
% [SETTINGS, X] = ROWEXCH(...,'PARAM1',VALUE1,'PARAM2',VALUE2,...) �́A
% �p�����[�^/�l�̑g���g���āA�v��쐬�̃R���g���[�������܂��B
% ���p�\�ȃp�����[�^�́A���̂悤�ɂȂ�܂��B
%
%      �p�����[�^   �l
%      'display'    �J��Ԃ��J�E���^�̕\�����R���g���[�����邽�߂ɁA
%                   'on'�A���邢�́A'off' �̂����ꂩ�ƂȂ�܂��B
%                   (�f�t�H���g = 'on').
%      'init'       NRUNS�~NFACTORS �s��Ƃ��Ă̏����v��
%                   (�f�t�H���g�́A�����_���ɑI�����ꂽ�_�W���ł�)�B
%      'maxiter'    �J��Ԃ��̍ő�� (�f�t�H���g = 10).
%
% �֐� ROWEXCH �́A�s�����A���S���Y�����g�p���āAD-�œK�v���T���܂��B
% ����́A�v��Ɋ܂܂��K�i�ȓ_�̌��W�����ŏ��ɐ������A���ꂩ��J��
% �Ԃ��A���̌v����g�p���Đ��肳���W���̕��U�����炷�悤�Ɏ��݂�ۂɁA
% ���̓_�ɑ΂���v��_���������܂��B�f�t�H���g�̂��̂ƈقȂ���W����
% �g�p����K�v������ꍇ�AROWEXCH �̑���� �֐� CANDGEN �� CANDEXCH ��
% �Ăяo�����Ƃ��ł��܂��B
%
% �Q�l : CORDEXCH, CANDGEN, CANDEXCH, X2FX.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:15:31 $
