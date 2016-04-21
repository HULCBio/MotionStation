%function [k,gfin] = sdhfsyn(sdsys,nmeas,ncon,.....
%                 gmin,gmax,tol,h,delay,ricmethd,epr,epp,quiet)
%
% ���̊֐��́A�T���v���l�f�[�^�V�X�e���ɑ΂���H��(��)�œKn��ԗ��U���ԃR
% ���g���[�����v�Z���܂��BBamieh and Pearson '92�̌��ʂ��g���āA�������
% �͌`�ԓI�ɗ��U���Ԃɕϊ�����܂��B���U���Ԗ��́A�A���n�ɑo�ꎟ�I�Ƀ}
% �b�v����܂��B���̂Ƃ��AGlover and Doyle�̘_��(1988)�̌��ʂ��g���܂��B
%
% �A�����ԃv�����gSDSYS�́A���̂悤�ɕ�������܂��B
%                        | a   b1   b2   |
%            sdsys    =  | c1   0    0   |
%                        | c2   0    0   |
% �����ŁAb2�́A������͂̐�����Ȃ��T�C�Y(NCON)�Ac2�́A�R���g���[����
% �^������ϑ�������Ȃ�s�T�C�Y(NMEAS)�ł��Bd�̓[���łȂ���΂Ȃ�܂�
% ��B
%
% ����:
%   SDSYS    -  ����݌v�̂��߂̑��݌����s��(�A������)
%   NMEAS    -  �R���g���[���ɓ��͂����ϑ��o�͂̐�(np2)
%   NCON     -  �R���g���[���o�͐�(nm2)
%   GMIN     -  gamma�̉��E(0���傫���Ȃ���΂Ȃ�܂���)
%   GMAX     -  gamma�̏�E
%   TOL      -  �ŏI��gamma��1�O��gamma�Ƃ̍��̋��e�͈�
%   H        -  �݌v�����R���g���[���̃T���v�����O����
%   DELAY    -  �R���g���[���̌v�Z��̒x���^����񕉂̐���(�f�t�H���g
%               ��0)
%   RICMETHD -  Riccati�������̉�@
%                 1 - �ŗL�l����(���t���t��)
%                -1 - �ŗL�l����(���t���Ȃ�)
%                 2 - ��schur����(���t���t���A�f�t�H���g)
%                -2 - ��schur����(���t���Ȃ�)
%   EPR      -  Hamiltonian�s��̌ŗL�l�̎��������[�����ǂ����̔���
%               (�f�t�H���g EPR = 1e-10)
%   EPP      -  x����������ł��邩�ǂ����̔���
%               (�f�t�H���g EPP = 1e-6)
%   QUIET    -  �T���v���f�[�^��H���C�^���[�V�����̏��̕\��
%                0 - ���ʂ�\�����܂���B
%                1 - ���ʂ��R�}���h�E�B���h�E�ɕ\�����܂�(�f�t�H���g)�B
%
% �o��:
%   K        -  H���R���g���[��(���U����)
%   GFIN     -  ����݌v�Ŏg����ŏIgamma�l 
%
%	                _________
%	               |         |
%	       <-------|  sdsys  |<--------
%	               |         |
%	      /--------|_________|<-----\
%	      |       __  		 |
%	      |      |d |		 |
%	      |  __  |e |   ___    __    |
%	      |_|S |_|l |__| K |__|H |___|
%	        |__| |a |  |___|  |__|
%	             |y |
%	             |__|
%
% �Q�l: DHFNORM, DHFSYN, DTRSP, H2SYN, H2NORM, HINFFI, HINFNORM,
%       RIC_EIG, RIC_SCHR, SDTRSP, SDHFNORM



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
