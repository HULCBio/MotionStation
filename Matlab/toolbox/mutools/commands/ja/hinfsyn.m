% function [k,g,gfin,ax,ay,hamx,hamy] = ....
%           hinfsyn(p,nmeas,ncon,gmin,gmax,tol,ricmethd,epr,epp,quiet)
%
% ���̊֐��́A�V�X�e��P�ɑ΂��āAH��(��)�œKn��Ԑ��䑥���v�Z���܂��B
% Glover and Doyle�̘_��(1988)�̌��ʂ��g���܂��BP�́A���̂悤�ɂȂ��
% ���B
%                        | a   b1   b2   |
%            p    =      | c1  d11  d12  |
%                        | c2  d21  d22  |
% �����ŁAb2�́A������͂̐�����Ȃ��T�C�Y(NCON)�Ac2�́A�R���g���[����
% �^������ϑ�������Ȃ�s�T�C�Y(NMEAS)�ł��B
%
% ����:
%   P        -  ����݌v�p�̑��݌����s��
%   NMEAS    -  �R���g���[���֓��͂����ϑ��o�͂̐�(np2)
%   NCON     -  �R���g���[���̏o�͐�(nm2)
%   GMIN     -  gamma�̉��E
%   GMAX     -  gamma�̏�E
%   TOL      -  �ŏI��gamma��1�O��gamma�Ƃ̍��̋��e�͈�
%   RICMETHD -  Riccati�������̉�@
%                  1 - �ŗL�l����(���t���t��)
%                 -1 - �ŗL�l����(���t���Ȃ�)
%                  2 - ��schur����(���t���t���A�f�t�H���g)
%                 -2 - ��schur����(���t���Ȃ�)
%   EPR      -  Hamiltonian�s��̌ŗL�l�̎��������[�����ǂ����̔���
%               (�f�t�H���g EPR = 1e-10)
%   EPP      -  x����������ł��邩�ǂ����̔���
%               (�f�t�H���g EPP = 1e-6)
%   QUIET    -  H���C�^���[�V�����Ɋւ�����̕\��
%                  0 - ���ʂ�\�����܂���B
%                  1 - ���ʂ��R�}���h�E�B���h�E�ɕ\��(�f�t�H���g)
%
%  �o��:
%    K       -   H���R���g���[��
%    G       -   ���[�v�V�X�e��
%    GFIN    -   ����݌v�Ŏg��ꂽ�ŏIgamma�l 
%    AX      -   �Ɨ��ϐ�gamma�Ɋ֘A����X-Riccati����VARYING�s��Ƃ��ďo
%                ��(�I�v�V����)
%    AY      -   �Ɨ��ϐ�gamma�Ɋ֘A����Y-Riccati����VARYING�s��Ƃ��ďo
%                ��(�I�v�V����)
%    HAMX    -   �Ɨ��ϐ�gamma�Ɋ֘A����X-Hamiltonian�s���VARYING�s���
%                ���ďo��(�I�v�V����)
%    HAMY    -   �Ɨ��ϐ�gamma�Ɋ֘A����Y-Hamiltonian�s���VARYING�s���
%                ���ďo��(�I�v�V����)
%
% �Q�l: H2SYN, H2NORM, HINFFI, HINFNORM, RIC_EIG, RIC_SCHR



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
