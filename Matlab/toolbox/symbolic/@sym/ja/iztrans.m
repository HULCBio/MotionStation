% IZTRANS   �t Z-�ϊ�
% f = IZTRANS(F) �́A�f�t�H���g�̓Ɨ��ϐ� z �����X�J���V���{���b�N�I�u
% �W�F�N�g F �̋t Z-�ϊ��ł��B�f�t�H���g�̏o�͂́An �̊֐� F = F(z) => 
% f = f(n) �ł��BF = F(n) �Ȃ�΁AIZTRANS �́Ak �̊֐� f = f(k) ���o�͂�
% �܂��B
% 
% f = IZTRANS(F, k) �́A�f�t�H���g�� n �̑���ɁAk �̊֐� f ���v�Z����
% ���B�����ŁAm �̓X�J���V���{���b�N�I�u�W�F�N�g�ł��B
% 
% f = IZTRANS(F, w, k) �́A�f�t�H���g�� symvar(F) �̑���ɁAw �̊֐�F
% ���v�Z���Ak �̊֐� F = F(w) �� f = f(k) ���o�͂��܂��B
%
% ��� :
% 
%      iztrans(z/(z-2)) �́A2^n ���o�͂��܂��B
%      iztrans(exp(x/z), z, k) �́Ax^k/k! ���o�͂��܂��B
%
% �Q�l�F ZTRANS, LAPLACE, FOURIER.



%   Copyright 1993-2002 The MathWorks, Inc.
