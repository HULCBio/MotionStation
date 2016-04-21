% function [k,g,norms,kfi,gfi,hamx,hamy] = ...
%		h2syn(plant,nmeas,ncon,ricmethod,quiet)
%
% ���`�������݌����\��P�ɑ΂��āAH2�œK�R���g���[��(K)�ƕ��[�v�V�X�e��
% (G)���v�Z���܂��BNMEAS��NCON�́AP����̐���o�͂̎����ƁAP�ւ̐������
% �ł��BRICMETHOD �́ARiccati�������̉�@�Ɏg�p�����@�����肵�܂��B
%
% ����:
%   PLANT     -   ���݌����\���s��(SYSTEM�s��) 
%   NMEAS     -   �R���g���[���ւ̊ϑ��o�͐�
%   NCON      -   ������͐�
%   RICMETHOD -   Riccati�������̉�@
%                   1 - �ŗL�l����(���t���t��)
%                  -1 - �ŗL�l����(���t���Ȃ�)
%                   2 - ��schur����(���t���t���A�f�t�H���g)
%                  -2 - ��schur����(���t���Ȃ�)
%   QUIET     -   X2��Y2�̍ŏ��ŗL�l�̕\��
%		    0 - ���ʂ��o�͂��܂���B
%		    1 - ���ʂ��R�}���h�E�B���h�E�ɕ\��(�f�t�H���g)
%
% �o��:
%   K         -  H2�œK�R���g���[��
%   G         -  H2�œK�R���g���[���������[�v�V�X�e��
%   NORMS     -  4�̈قȂ�ʂ̃m�����B�S��񐧌�]��(FI)�A�o�͐���]��
%                (OEF)�A���ڃt�B�[�h�o�b�N�]��(DFL)�A�S����]��(FC)�B
%                   norms = [FI OEF DFL FC];
%                   h2norm(g) = sqrt(FI^2 + OEF^2) = sqrt(DFL^2 + FC^2)
%   KFI       -  �S���/��ԃt�B�[�h�o�b�N���䑥
%   GFI       -  �S���/��ԃt�B�[�h�o�b�N���[�v�V�X�e��
%   HAMX      -  X Hamiltonian�s��
%   HAMY      -  Y Hamiltonian�s��
%
% �Q�l: H2NORM, HINFSYN, HINFFI, HINFNORM, RIC_EIG, RIC_SCHR.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
