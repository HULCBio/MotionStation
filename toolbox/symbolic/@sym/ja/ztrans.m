% ZTRANS   Z-�ϊ�
% F = ZTRANS(f) �́A�f�t�H���g�̓Ɨ��ϐ� n �Ɋւ���X�J���V���{���b�N�� 
% f �� z-�ϊ��ł��B�f�t�H���g�̏o�͂́Az �̊֐� f = f(n) => F = F(z) ��
% ���Bf �� Z-�ϊ��́A���̂悤�ɒ�`����܂��B
%     
%     F(z) = symsum(f(n)/z^n, n, 0, inf)
%   
% �����ŁAn �́AFINDSYM �Ō��肳���悤�� f �̃V���{���b�N�ϐ��ł��Bf =
% f(z) �Ȃ�΁AZTRANS(f) �́Aw �̊֐� F = F(w) ���o�͂��܂��B
%
% F = ZTRANS(f, w) �́A�f�t�H���g��z�̑���ɁAw �̊֐�F���o�͂��܂��B 
% 
%    ZTRANS(f,w) <=> F(w) = symsum(f(n)/w^n, n, 0, inf)
%
% F = ZTRANS(f, k, w) �́A�V���{���b�N�ϐ� k �̊֐� f ��ϊ����܂��B
% 
%    ZTRANS(f,k,w) <=> F(w) = symsum(f(k)/w^k, k, 0, inf)
%
% ��� :
%     syms k n w z
%     ztrans(2^n) �́Az/(z-2) ���o�͂��܂��B
%     ztrans(sin(k*n),w) �́Asin(k)*w/(1-2*w*cos(k)+w^2) ���o�͂��܂��B
%     ztrans(cos(n*k),k,z) �́Az*(-cos(n)+z)/(-2*z*cos(n)+z^2+1) ���o��
%     ���܂��B
%     ztrans(cos(n*k),n,w) �́Aw*(-cos(k)+w)/(-2*w*cos(k)+w^2+1) ���o��
%     ���܂��B
%     ztrans(sym('f(n+1)')) �́Az*ztrans(f(n),n,z)-f(0)*z ���o�͂��܂��B
% 
% �Q�l�F IZTRANS, LAPLACE, FOURIER.



%   Copyright 1993-2002 The MathWorks, Inc.
