% function out = daug(mat1,mat2,mat3...,matN,[memstr])
%
% SYSTEM/VARYING/CONSTANT�s���Ίp�Ɋg�債�܂��B���͍s��́A�ő�9�ɐ�
% ������Ă��܂��B
%
%          |  mat1  0     0    .   0   |
%          |   0   mat2   0    .   0   |
%    out = |   0    0    mat3  .   0   |
%          |   .    .     .    .   .   |
%          |   0    0     0    .  matN |
%
% memstr�́A�R�}���h�̎��s�ɂ����ă������̎g�p�ʂ��ŏ������邩�ǂ������
% �肷�镶����ϐ��ł��Bmemstr = "min_mem"�̏ꍇ�AVARYING�s���for���[�v
% ���ɃX�^�b�N����܂��B����ɂ��A���s�͂��x���Ȃ�܂����A�������g�p
% �ʂ��������Ȃ�܂��B�������������Ă���}�V����ŋ���Ȏ����f�[�^����
% �舵���Ƃ��ɁA���̋@�\���g���܂��B
%
% �Q�l: ABV, MADD, MMULT, SBS, SEL, VDIAG



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
