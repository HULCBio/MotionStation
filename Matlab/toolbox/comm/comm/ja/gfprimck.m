% GFPRIMCK   �K���A�̏�̑����������n�I�ł��邩�ǂ����`�F�b�N
%
% CK = GFPRIMCK(A) �́A���� M �� GF(2) �̑����� A �� GF(2^M) �ɑ΂���
% ���n�������ł��邩�ǂ������`�F�b�N���܂��B������ M = length(A)-1 �ł��B
% �o�� CK �͂��̂悤�ɂȂ�܂��B
%    CK = -1   A �͊��񑽍����łȂ��B
%    CK =  0   A �͊��񑽍����ł��邪���n�������ł͂Ȃ��ꍇ
%    CK =  1   A �͌��n�������ł���B
% 
% CK = GFPRIMCK(A, P) �́A���� M �� GF(P) �̑����� A ���AGF(P^M) ��
% �΂��Ă̌��n�������ł��邩�ǂ������`�F�b�N���܂��BP �͑f���ł��B
% 
% �s�x�N�g�� A �́A���x�L�̏��ɕ��ׂ�ꂽ�������̌W�������X�g���邱�Ƃ�
% ����āA��������\�����܂��B
% ���:  GF(5) �ŁAA = [4 3 0 2] �� 4 + 3x + 2x^3 ��\�����܂��B
%
% �Q�l�F GFPRIMFD, GFPRIMDF, GFTUPLE, GFMINPOL, GFADD.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $   $Date: 2003/06/23 04:34:42 $
