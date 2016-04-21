% function [k,g,gfin,ax,hamx] = hinffi(p,ncon,gmin,gmax,tol,ricmethd,epr,epp)
%
% ���̊֐��́A�V�X�e��P�ɑ΂��āA�S���H��n��ԃR���g���[�����v�Z���܂��B
% Glover and Doyle�̘_��(1988)�̌��ʂ��g���܂��B���́A���ׂĂ̏�ԂƊO��
% ������ł���Ɖ��肵�܂��B�s��P�́A���̌`���ł��B
%
%     p  =  | ap  | b1   b2  |
%           | c1  | d11  d12 |
%
% �S���R���g���[���������[�v�����Ƃ��ɂ́A���ӂ��K�v�ł��B�t�B�[
% �h�o�b�N�ɑ΂��āA���݌����\��P�́A��ԂƊO���̊ϑ��ʂ����悤�Ɋg��
% ����Ȃ���΂Ȃ�܂���B
%
% ����:
%    P        -   ����݌v�p�̑��݌����s��
%    NCON     -   �R���g���[���o�͐�(nm2)
%    GMIN     -   gamma�̉��E
%    GMAX     -   gamma�̏�E
%    TOL      -   �ŏI��gamma��1�O��gamma�Ƃ̈Ⴂ�̋��e�͈�
%    RICMETHD - Ricatti�������̉�@
%                   1 - �ŗL�l����(���t���t��)
%                  -1 - �ŗL�l����(���t���Ȃ�)
%                   2 - ��schur����(���t���t���A�f�t�H���g)
%                  -2 - ��schur����(���t���Ȃ�)
%    EPR      -   Hamiltonian�s��̌ŗL�l�̎��������[�����ǂ����̔����
%                 ��(�f�t�H���g EPR = 1e-10)
%    EPP      -   x����������s��ł��邩�ǂ����̔���(�f�t�H���g 
%                 EPP = 1e-6)
%
% �o��:
%    K        -   H���S���R���g���[��
%    G        -   ���[�v�V�X�e��
%    GFIN     -   ����݌v�Ɏg����ŏI��gamma�l 
%    AX       -   �Ɨ��ϐ�gamma�Ɋ֘A����Riccati����VARYING�s��Ƃ��ďo
%                 ��(�I�v�V����)
%    HAMX     -   �Ɨ��ϐ�gamma�Ɋ֘A����Hamiltonian�s���VARYING�s���
%                 ���ďo��(�I�v�V����)



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
