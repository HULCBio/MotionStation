% FORTRAN   �V���{���b�N���� Fortran �\��
% FORTRAN(S) �́A�V���{���b�N�� S ��]������ Fortran �̃t���O�����g�ł��B
%
% ��� :
%      syms x
%      f = taylor(log(1+x));
%      fortran(f) =
%
%         t0 = x-x**2/2+x**3/3-x**4/4+x**5/5
%
%      H = sym(hilb(3));
%      fortran(H) =
%
%        H(1,1) = 1            H(1,2) = 1.E0/2.E0    H(1,3) = 1.E0/3.E0
%        H(2,1) = 1.E0/2.E0    H(2,2) = 1.E0/3.E0    H(2,3) = 1.E0/4.E0
%        H(3,1) = 1.E0/3.E0    H(3,2) = 1.E0/4.E0    H(3,3) = 1.E0/5.E0
%
% �Q�l�F PRETTY, LATEX, CCODE.



%   Copyright 1993-2002 The MathWorks, Inc.
