% function [sys,fit,extracons] = magfit(vmagdata,dim,wt)
%
% MAGFIT�́A�^����ꂽ���g���̈�d�݊֐�WT���g���āA�Q�C���f�[�^VMAGDATA
% ������ȍŏ��ʑ��`�B�֐��ŋߎ����܂��BVMAGDATA�́A��v����Q�C���Ǝ��g
% ���_��^����VARYING�s��ł��B
%
%   [mag,rowpoint,omega,err] = vunpck(vmagdata)
%
% DIM�́A1�s4��x�N�g���ŁAdim= [hmax,htol,nmin,nmax]�ł��B�o��SYSTEM�s
% ��SYS�́A���𖞂�������ȍŏ��ʑ�SISO�V�X�e���ł��B
%
%        1/(1+ h/W) < g^2/mag^2 < 1+ h/W
%
% �����ŁAg��[W,rowpoint,omega,err] = vunpck(WT)�̂Ƃ��A���g��omega�ɑ�
% ����SYS�̎��g�������̑傫���ł��BSYS�̎�����N�ŁA0<=NMIN<=N<=NMAX��H<=
% HMAX�𖞂����ŏ������ł��B���̂悤��n�����݂��Ȃ��Ƃ��́AN=NMAX�ɂȂ�
% �܂��BH�̒l�́Ahupper-hlower<=HTOL�̂Ƃ��ɏ�E�Ɖ��E�̊Ԃŋߎ��I�ɍŏ�
% ������܂��BFIT�́AH�̓��B�l�ł��B
%
% �Q�l: FITMAG, FITMAGLP, MUSYNFIT, MUSYNFLP.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
