% ARXDATA �́A���ϐ� SISO IDPOLY ���f���p�� ARX ���������o�͂��܂��B
%
%   [A,B] = ARXDATA(M)
%
%   M : IDPOLY ���f���I�u�W�F�N�g�Bhelp IDPOLY ���Q�ƁB
%
%   A, B : �Ή����� ARX ������
%
%   y(t) + A1 y(t-1) + .. + An y(t-n) = 
%          = B0 u(t) + ..+ B1 u(t-1) + .. + Bm u(t-m)
%
%
% [A,B,dA,dB] = ARXDATA(M) ���g���āAA �� B �̕W���΍��AdA �� dB ���v�Z
% ���܂��B
%
% �Q�l�F IDARX, IDPOLY, ARX

%   L. Ljung 10-2-90,3-13-93


%   Copyright 1986-2001 The MathWorks, Inc.
