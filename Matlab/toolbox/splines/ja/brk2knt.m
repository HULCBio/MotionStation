% BRK2KNT   ���d�x�����u���[�N�|�C���g�񂩂�ߓ_����쐬
%
% T = BRK2KNT(BREAKS,MULTS) �́A���ׂĂ�i�ɑ΂��āABREAKS(i) �� MULTS(i)��
% �J��Ԃ��ꂽ�`�̐ߓ_�� T ���o�͂��܂��BBREAKS �������ȈӖ��ő�������
% �ꍇ�AT �́A�e BREAKS(i) �����m�� MULTS(i)�񔭐�����ߓ_��ł��B
%
% MULTS ���萔�ł���ׂ��ꍇ�A���̒萔�l�݂̂��^������K�v������܂��B 
%
% [T,INDEX] = BRK2KNT(BREAKS,MULTS) �́AINDEX = [1 find(diff(T)>0)-1] ��
% �o�͂��܂��B���ׂĂ̑��d�x�����Ȃ�΁A���ׂĂ� j �ɑ΂��� INDEX(j) ��
% T �̒��� BREAKS(j) �������ŏ��̈ʒu�ł��B
%
% ���:
%    t = brk2knt(1:2,3)
% �́At = [1 1 1 2 2 2] ��^���܂��B����A
%
%    t = [1 1 2 2 2 3 4 5 5];  [xi,m] = knt2brk(t);  tt = brk2knt(xi,m);
%
% �ł́Axi �� [1 2 3 4 5]�Am �� [2 3 1 1 2]�Att �� t ��^���܂��B
%
% �Q�l : KNT2BRK, KNT2MLT, AUGKNT.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc. 
