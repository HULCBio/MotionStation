% function [u,t,k]=orsf(u,a,fl,bord)
%
%  *****  UNTESTED SUBROTUINE  *****
%
% �s��A����Schur�^�ŗ^����ƁAORSF�́AT = U'*A*U�����߂܂��B�����ŁAU��
% ���j�^���s��ł��BFL = 'o'�̏ꍇ�AT�̌ŗL�l�͎������̏����ɕ��ׂ���
% ���܂��B�܂��́AFL = 's'�̏ꍇ�AT�̌ŗL�l��2�̃O���[�v�ɕ��ׂ��A��
% ���̃O���[�v�̌ŗL�l�̎�������BORD��菬�����Ȃ�܂��BBORD�̃f�t�H���g
% �l�̓[���ł��BK�́A��������BORD�����������ɂ̐��ł��B
%
% �Q�l: OCSF

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:32:09 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
