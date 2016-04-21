% ILAPLACE   �t���v���X�ϊ�
% F = ILAPLACE(L) �́A�f�t�H���g�̓Ɨ��ϐ�s�����X�J���V���{���b�N�I�u
% �W�F�N�gL�̋t���v���X�ϊ��ł��B�f�t�H���g�̏o�͂́At �̊֐��ł��BL = 
% L(t) �Ȃ�΁AILAPLACE �́Ax �̊֐� F = F(x) ���o�͂��܂��B��`�ɂ��A
% F(t) = int(L(s)*exp, (s*t), s, c-i*inf, c+i*inf) �ŁA�����ŁAc �͎���
% �l�ŁAL(s) �̂��ׂĂ̓��ٓ_�����C�� s = c �̍����ɂȂ�悤�ɑI�����A
% i = sqrt(-1) �ŁA�ϕ��� s �ɂ��Čv�Z����܂��B
%
% F = ILAPLACE(L, y)�́A�f�t�H���g�� t �̑���ɁAy �̊֐�F���v�Z���܂��B
% 
%      ILAPLACE(L,y) <=> F(y) = int(L(y)*exp(s*y),s,c-i*inf,c+i*inf)
% 
% �����ŁAy �̓X�J���V���{���b�N�I�u�W�F�N�g�ł��B
%
% F = ILAPLACE(L, y, x) �́A�f�t�H���g��t�̑���ɁAx �̊֐�F���v�Z���A
% y �ɂ��Đϕ����܂��B
%   
%    ILAPLACE(L,y,x) <=> F(y) = int(L(y)*exp(x*y),y,c-i*inf,c+i*inf)
%
% ��� :
%      syms s t w x y
%      ilaplace(1/(s-1)) �́Aexp(t) ���o�͂��܂��B
%      ilaplace(1/(t^2+1)) �́Asin(x) ���o�͂��܂��B
%      ilaplace(t^(-sym(5/2)),x) �́A4/3/pi^(1/2)*x^(3/2) ���o�͂��܂��B
%      ilaplace(y/(y^2 + w^2),y,x) �́Acos(w*x) ���o�͂��܂��B
%      ilaplace(sym('laplace(F(x),x,s)'),s,x) �́AF(x) ���o�͂��܂��B
%
% �Q�l�F LAPLACE, IFOURIER, IZTRANS.



%   Copyright 1993-2002 The MathWorks, Inc.
