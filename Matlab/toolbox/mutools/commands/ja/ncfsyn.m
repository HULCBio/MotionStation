% function  [sysk,emax,sysobs]=ncfsyn(sysgw,factor,opt)
%
% �V�X�e���L�q�̐��K�����ꂽ������q�̒��̕s�m�����̑傫���ɂ��^�����
% ��V�X�e���Q�����o�X�g���艻������R���g���[����݌v���܂��B
%
% ����:
% -------
%  SYSGW  - ���䂳���d�ݕt���V�X�e��
%  FACTOR - =1 �œK�R���g���[�����K�v�Ƃ���܂��B
%           >1 �œK���኱���\��������FACTOR�l��B�����鏀�œK�R���g��
%              �[�����K�v�Ƃ���܂��B
%  OPT    - 'ref'�́A���t�@�����X���͂��܂݂܂�(�I�v�V����)�B
%
% �o��:
% -------
%  SYSK   -  H�����[�v���`�R���g���[��
%  EMAX   -  ��\���I�ۓ��Ɋւ��郍�o�X�g���̎w�W�Ƃ��Ă̈���]�T�BEMAX
%            �́A�K��1��菬�����A0.3����������EMAX�̒l�́A�ʏ�ǂ���
%            �o�X�g���������܂��B
%  SYSOBS -  H�����[�v���`�I�u�U�[�o�R���g���[���B���̕ϐ��́AFACTOR>1��
%            OPT = 'ref'�̂Ƃ��̂ݍ쐬����܂��B
%
% �Q�l: HINFNORM, HINFSYN, NUGAP



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
