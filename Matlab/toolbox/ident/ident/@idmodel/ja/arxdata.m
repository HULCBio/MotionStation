% ARXDATA �́A���ϐ� IDARX ���f���� ARX ���������o�͂��܂��B
%
%   [A,B] = ARXDATA(M)
%
%   M : IDARX ���f���I�u�W�F�N�g�Bhelp IDARX ���Q�ƁB
%
%   A, B : ny-ny-n �� ny-nu-m �̍s��ŁAARX �\�����`���܂�
%          (ny:�o�͐��Anu:���͐�)
%
%   y(t) + A1 y(t-1) + .. + An y(t-n) = 
%          = B0 u(t) + ..+ B1 u(t-1) + .. + Bm u(t-m)
%
%          A(:,:,k+1) = Ak,  B(:,:,k+1) = Bk
%
% [A,B,dA,dB] = ARXDATA(M) ���g���āAA �� B �̕W���΍��AdA �� dB ���v�Z��
% �܂��B
%
% �Q�l�F IDARX, ARX

%   L. Ljung 10-2-90,3-13-93


%   Copyright 1986-2001 The MathWorks, Inc.
