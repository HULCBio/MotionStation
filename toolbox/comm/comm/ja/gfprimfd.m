% GFPRIMFD   �K���A�̂ɂ��Ă̌��n�������̌��o 
%
% PR = GFPRIMFD(M) �́AGF(2^M) ��̎��� M �̌��n�����������o���܂��B
%
% PR = GFPRIMFD(M, OPT) �́AGF(2^M) ��̌��n�����������o���܂��B
%       OPT = 'min'  �́A�ŏ��d�݂̌��n�����������o���܂��B
%       OPT = 'max'  �́A�ő�d�݂̌��n�����������o���܂��B
%       OPT = 'all'  �́A���ׂĂ̌��n�����������o���܂��B 
%       OPT = L      �́A�d�� L �̂��ׂĂ̌��n�����������o���܂��B
% 
% PR = GFPRIMFD(M, OPT, P) �́A2��f�� P �ƒu�������邱�ƈȊO�́A
% PR = GFPRIMFD(M, OPT) �Ɠ����ł��B
%
% �o�͍s�x�N�g�� PR �́A���x�L�̏��ɕ��ׂ��Ă���W���̃��X�g�ɂ����
% ��������\�����܂��B
% ���: GF(5) �ŁAA = [4 3 0 2] �� 4 + 3x + 2x^3 ��\�����܂��B
%
% OPT = 'all' �܂��� L �ŁA�����̌��n������������𖞂����ꍇ�APR �̊e�s
% �͈قȂ鑽������\�����܂��B����𖞂������n���������Ȃ��ꍇ�́APR ��
% ��s��ɂȂ�܂��B
%
% �Q�l:  GFPRIMCK, GFPRIMDF, GFTUPLE, GFMINPOL.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $   $Date: 2003/06/23 04:34:44 $
