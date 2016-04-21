% function [k,g,gfin,ax,ay,hamx,hamy] =
%         dhfsyn(p,nmeas,ncon,gmin,gmax,tol,h,z0,quiet,ricmethd,epr,epp)
%
% ���̊֐��́A���U���ԃV�X�e��P�ɑ΂��āA�A�����Ԃւ̑o�ꎟ�ω����g���A
% ���̌�ANINFSYNE���Ăяo�����Ƃɂ���āAH��(��)�œKn��ԃR���g���[����
% �v�Z���܂��B�V�X�e��P�́A���̂悤�ɕ�������܂��B
%                        | a   b1   b2   |
%            p    =      | c1  d11  d12  |
%                        | c2  d21  d22  |
% �����ŁAb2�́A������͂̐�����Ȃ��T�C�Y(NCON)�Ac2�́A�R���g���[����
% �^������ϑ�������Ȃ�s�T�C�Y(NMEAS)�ł��Bz=z0�ŋɒl�����G���g��
% �s�[����^���܂��B
%
% ����:
%    P        -   ����݌v�̂��߂̑��݌����s��(���U����)
%    NMEAS    -   �R���g���[���ɓ��͂����ϑ��o�͂̐�(np2)
%    NCON     -   ����o�͐�(nm2)
%    GMIN     -   gamma�̉��E
%    GMAX     -   gamma�̏�E
%    TOL      -   �ŏI��gamma��1�O��gamma�Ƃ̍��̋��e�͈�
%    H        -   �T���v�����O����(�f�t�H���g=1)
%    Z0       -   �G���g���s�[���ɒl�ƂȂ�_(ABS(Z0)>1)(�f�t�H���g Z0=inf)�B
%                 ABS(Z0)>1�̏ꍇ�A���ׂẲ��́Agfin��菬����Phi�̃m��
%                 �����g����starp(K,Phi)�̂悤�ɁAK��G�Ńp�����[�^������
%                 �܂��B
%    QUIET    -   �X�N���[����̕\���@
%                   1 - �\���Ȃ�
%                   0 - �w�b�_�Ȃ��̕\��
%                  -1 - ���ׂĂ�\��(�f�t�H���g)
%    RICMETHD -   Riccati��
%                   1 - �ŗL�l����(���t���t��)
%                  -1 - �ŗL�l����(���t���Ȃ�)
%                   2 - ��schur����(���t���t���A�f�t�H���g)
%                  -2 - ��schur����(���t���Ȃ�)
%    EPR      -   Hamiltonian�s��̌ŗL�l�̎��������[�����ǂ����̔����
%                 ��(�f�t�H���g EPR = 1e-10)
%    EPP      -   x����������ł��邩�ǂ����̔���(�f�t�H���g EPP = 
%                 1e-6)
%
%  �o��:
%    K       -   H���R���g���[��(���U����)
%    G       -   ���[�v�V�X�e��(���U����)
%    GFIN    -   ����݌v�Ŏg����ŏIgamma�l 
%    AX      -   �Ɨ��ϐ�gamma�Ɋ֘A����X-Riccati����VARYING�s��Ƃ���
%                �o��(�I�v�V����)	
%    AY      -   �Ɨ��ϐ�gamma�Ɋ֘A����Y-Riccati����VARYING�s��Ƃ���
%                �o��(�I�v�V����)
%    HAMX    -   �Ɨ��ϐ�gamma�Ɋ֘A����X-Hamiltonian�s���VARYING�s��
%                �Ƃ��ďo��(�I�v�V����)
%    HAMY    -   �Ɨ��ϐ�gamma�Ɋ֘A����Y-Hamiltonian�s���VARYING�s��
%                �Ƃ��ďo��(�I�v�V����)
%
% �Q�l: DHFNORM, DTRSP, H2SYN, H2NORM, HINFFI, HINFNORM, RIC_EIG, 
%       RIC_SCHR, SDHFNORM, SDHFSYN, SDTRSP



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
