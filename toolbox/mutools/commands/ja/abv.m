% function out = abv(mat1,mat2,mat3...,matN,[memstr])
%
% VARYING/SYSTEM/CONSTANT�s����ォ�珇�Ɍ������܂��B
%
%                        |  mat1  |
%                        |  mat2  |
%          out    =      |  mat3  |
%                        |   ..   |
%                        |  matN  |
%
% memstr�́A�R�}���h�̎��s�ɂ����āA�������̎g�p�ʂ��ŏ������邩�ǂ�����
% �ݒ肷�镶����ϐ��ł��Bmemstr = "min_mem"�̏ꍇ�AVARYING�s���for���[
% �v���ɃX�^�b�N����܂��B����ɂ��A���s�́A���x���Ȃ�܂����A������
% �g�p�ʂ��������Ȃ�܂��B�������������Ă���}�V����ŋ���Ȏ����f�[�^
% ����舵���Ƃ��ɁA���̋@�\���g���܂��B
%
% �Q�l: MADD, DAUG, MMULT, SBS, SEL, VDIAG.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
