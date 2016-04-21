% function [dsysl,dsysr] = musynfit(pre_dsysl,Ddata,sens,blk,nmeas,...
%                             ncntrl,clpg,upbd,wt)
%
% DDATA�f�[�^��D���g������(PRE_DSYSL)����Z���邱�Ƃɂ�蓾����Q�C��
% �J�[�u���ߎ����܂��B����ȁA�ŏ��ʑ��V�X�e���s��DSYSL��DSYSR���o�͂��A
% �����́A(MMULT���g����)��Z�ɂ���ăI���W�i���̑��݌����\���ɑg�ݍ�
% �܂�A(MINV���g����)�t�s����o�͂��܂��B��x�g�ݍ��܂��ƁAH���݌v�́A
% MU�V���Z�V�X�̕ʂ̃C�^���[�V�����ɂ���Ď��s����܂��B
%
% �ŏ���MU�V���Z�V�X�C�^���[�V�����Ɋւ��ẮA�ϐ�PRE_DSYSL�ɕ�����'fi-
% rst'��ݒ肵�܂��B�A���I�ɃC�^���[�V�����𑱂���ɂ́APRE_DSYSL�́A1��
% �O��(��)�L��D�X�P�[�����O�V�X�e���s��DSYSL��ݒ肵�Ȃ���΂Ȃ�܂���B
%
% (�I�v�V����)�ϐ�CLPG�́ADDATA, SENS, UPBD�f�[�^���쐬�����s��ł��BDD-
% ATA���ߎ�����Ƃ��ɁA����ȍŏ��ʑ��V�X�e���s��DSYSL��DSYSR�́A�I���W
% �i���̍s��CLPG�ɑg�ݍ��܂�AUPBD�f�[�^�Ƌ��Ƀv���b�g����܂��B������
% 2�̃v���b�g���r���邱�Ƃ́A�L���V�X�e���s��DSYSL��DSYSR���A�ǂ̒�
% �xDDATA���ߎ����Ă��邩�Ɋւ��ē��@��^���܂��B�V�K�ɃX�P�[�����O����
% ���s��DMDI���o�͂���܂��B����́ADSYSL��DSYSR���g�ݍ��܂�Ă���CLPG��
% ���BCLPG��UPBD���^�����Ȃ���΁A�f�t�H���g��SENS�ϐ������Ƀv���b
% �g���܂��B
%
% �I�v�V�����̕ϐ�WT���g���āADDATA�ɏd�ݕt���邱�Ƃ��ł��܂��B�f�t�H��
% �g�́ADDATA�ɑ΂��ĕt���I�ȏd�ݕt�����s���܂���B
%
% FITMAG�̑����FITMAGLP���Ăяo����邱�Ƃ������āAMUSYNFIT�Ɠ����ŁA
% ���̃R�}���h�ł�MAGFIT���Ăяo���܂��B
%
% �Q�l: DKIT, FITMAGLP, FITSYS, MAGFIT, MUFTBTCH, MUSYNFIT.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
