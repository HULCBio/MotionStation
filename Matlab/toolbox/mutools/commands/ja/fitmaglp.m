% function [sys] = fitmaglp(magdata,wt,heading,osysl_g,...
%                              dmdi,upbd,blk,blknum)
%
% FITMAGLP�́A�^����ꂽ���g���d�݊֐�WT���g���āA�Q�C���f�[�^MAGDATA��
% ����ȍŏ��ʑ��`�B�֐��ŋߎ����܂��B�����̓��͈����́A���ɓ����Ɨ���
% ���l������VARYING �s��ł��B
%
% HEADING(�I�v�V����)�́A�\�������^�C�g���ŁAOSYSL_G(�I�v�V����)�́A�O
% �̋ߎ���FRSP�ł��B����炪�^������΁A�f�[�^�Ƌ��ɕ\������܂��B
%
% (�I�v�V����)�ϐ�DMDI�́AMAGDATA, WT, UPBD�f�[�^���쐬�����s��ł��BD��
% �ߎ�����Ƃ��ɁA����ȍŏ��ʑ��V�X�e���s��SYS�́A�I���W�i���̍s��DMDI
% �ɑg�ݍ��܂�AUPBD�f�[�^�Ƌ��Ƀv���b�g����܂��BBLK�́AMU�R�}���h�Ŏg
% ���u���b�N�\���ŁABLKNUM�́A�ߎ������J�����g��D�X�P�[�����O���`��
% �܂��B
%
% ������2�̃v���b�g���r���邱�Ƃ́A�L���V�X�e���s��SYS���ǂ̒��xD
% �f�[�^���ߎ����Ă��邩�Ɋւ��ē��@��^���܂��B�V�K�ɃX�P�[�����O���ꂽ
% �s��DMDI���o�͂���܂��B����́ASYS���g�ݍ��܂�Ă���CLPG�ł��BDMDI, 
% UPBD, BLK, BLKNUM���^�����Ȃ���΁A�f�t�H���g�ł�WT�ϐ������Ƀv
% ���b�g���܂��B�����̃I�v�V�����́AMUSYNFIT�Ŏg���܂��B
%
% GENPHASE�����FITSYS�̑����MAGFIT���g���邱�ƈȊO�́AFITMAG�Ɠ���
% �ł��B
%
% �Q�l: FITSYS, INVFREQS, FITMAG, MUSYNFIT, MUFTBTCH, MUSYNFLP.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
