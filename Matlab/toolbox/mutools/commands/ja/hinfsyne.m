% function [k,g,gfin,ax,ay,hamx,hamy] = ....
%      hinfsyne(p,nmeas,ncon,gmin,gmax,tol,s0,quiet,ricmethd,epr,epp)
%
% ���̊֐��́A�V�X�e��P�ɑ΂��āAH��(��)�œKn��Ԑ��䑥���v�Z���܂��B
% Glover and Doyle�̘_��(1988)�̌��ʂ��g���܂��B�V�X�e��P�́A���̌`��
% �ł��B
%                        | a   b1   b2   |
%            p    =      | c1  d11  d12  |
%                        | c2  d21  d22  |
% �����ŁAb2�́A������͂̐�����Ȃ��T�C�Y(NCON)�Ac2�́A�R���g���[����
% �^������ϑ�������Ȃ�s�T�C�Y(NMEAS)�ł��Bs = s0�ŋɒl�����G���g
% ���s�[����^���܂��B
%
% ����:
%   P        -  ����݌v�̂��߂̑��݌����s��
%   NMEAS    -  �R���g���[���ɓ��͂����ϑ��o�͂̐�(np2)
%   NCON     -  �R���g���[���o�͐�(nm2)
%   GMIN     -  gamma�̉��E
%   GMAX     -  gamma�̏�E
%   TOL      -  �ŏI��gamma��1�O��gamma�Ƃ̍��̋��e�͈�
%   S0       -  �G���g���s�[���ɒl�ƂȂ�_(>0)(�f�t�H���g S0=inf)�BS0<=0
%               �̏ꍇ�A���ׂẲ���gfin��菬����Phi�̃m�������g����st-
%               arp(K,Phi)�̂悤��K��G�ŁA�p�����[�^������܂��B
%   QUIET    -  �X�N���[����̐���̕\��
%                  1 - �\���Ȃ�
%                  0 - �w�b�_�Ȃ��̕\��
%                 -1 - ���ׂĂ�\��(�f�t�H���g)
%   RICMETHD -  Riccati�������̉�@
%                  1 - �ŗL�l����(���t���t��)
%                 -1 - �ŗL�l����(���t���Ȃ�)
%                  2 - ��schur����(���t���t���A�f�t�H���g)
%                 -2 - ��schur����(���t���Ȃ�)
%   EPR      -  Hamiltonian�s��̌ŗL�l�̎��������[�����ǂ����̔���
%               (�f�t�H���g EPR = 1e-10)
%   EPP      -  x����������ł��邩�ǂ����̔���
%               (�f�t�H���g EPP = 1e-6)
%
%  �o��:
%   K       -  H���R���g���[��
%   G       -  ���[�v�V�X�e��
%   GFIN    -  ����݌v�Ŏg��ꂽ�ŏIgamma�l 
%   AX      -  �Ɨ��ϐ�gamma�Ɋ֘A����X-Riccati����VARYING�s��Ƃ��ďo��
%              (�I�v�V����)
%   AY      -  �Ɨ��ϐ�gamma�Ɋ֘A����Y-Riccati����VARYING�s��Ƃ��ďo��
%              (�I�v�V����)
%   HAMX    -  �Ɨ��ϐ�gamma�Ɋ֘A����X-Hamiltonian�s���VARYING�s��Ƃ�
%              �ďo��(�I�v�V����)
%   HAMY    -  �Ɨ��ϐ�gamma�Ɋ֘A����Y-Hamiltonian�s���VARYING�s��Ƃ�
%              �ďo��(�I�v�V����)
%
% �Q�l: DHFSYN, H2SYN, H2NORM, HINFFI, HINFNORM, RIC_EIG, RIC_SCHR,
%       SDHFNORM, SDHFSYN



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
