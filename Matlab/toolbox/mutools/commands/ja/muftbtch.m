% function [dsysl,dsysr] = ...
%   muftbtch(pre_dsysl,Ddata,sens,blk,nmeas,ncntrl,dim,wt)
%
% DDATA�f�[�^��D���g������(PRE_DSYSL)����Z���邱�Ƃɂ�蓾����Q�C��
% �J�[�u���ߎ����܂��B����ȁA�ŏ��ʑ��V�X�e���s��DSYSL��DSYSR���o�͂��A
% �����́A(MMULT���g����)��Z�ɂ���ăI���W�i���̑��݌����\���ɑg�ݍ�
% �܂�A(MINV���g����)�t�s����o�͂��܂��B��x�g�ݍ��܂��ƁAH���݌v�́A
% mu�V���Z�V�X�̕ʂ̃C�^���[�V�����ɂ���Ď��s����܂��B
%
% �ŏ���MU�V���Z�V�X�C�^���[�V�����Ɋւ��ẮA�ϐ�PRE_DSYSL�ɕ�����'fi-
% rst'��ݒ肵�܂��B�A���I�ɃC�^���[�V�����𑱂���ɂ́APRE_DSYSL�́A1��
% �O��(��)�L��D�X�P�[�����O�V�X�e���s��DSYSL��ݒ肵�Ȃ���΂Ȃ�܂���B
%
% MAGFIT�ɑ΂��āAdim=[hmax,htol,nmin,nmax]�Ɛݒ肵�܂�(dim=[.26,.1,0,3]
% �́A�\�ȏꍇ�́A���x��1dB�ŁA3���̋ߎ��𓾂܂�)�B
%
% �Q�l: FITMAG, FITSYS, MAGFIT, MUSYNFIT, MUFTBTCH, MUSYNFLP.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
