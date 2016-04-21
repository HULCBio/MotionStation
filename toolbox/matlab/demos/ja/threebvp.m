%THREEBVP  3�_���E�l���
%
%   ���_���E�l���(multipoint BVPs) �̂��̗�́A���̘_���ɏq�ׂ�ꂽ
%   �����w�ł̗���̖��̌����ɂ������炳�ꂽ���̂ł��B
%   C.Lin and L.Segel, Mathematics Applied to Deterministic Problems 
%   in the Natural Sciences, SIAM, Philadelphia, PA, 1988.
%   [0, lambda] �� x �ɑ΂��āA���ɑ΂���������́A���m�p�����[�^ 
%   n, kappa, �� lambda > 1�Ceta = lambda^2/(n*kappa^2) �ɑ΂��āA
%
%       v' = (C - 1)/n
%       C' = (vC - min(x,1))/eta
%
%   �ł��BC'(x) �ɑ΂���������ɂ����鍀 min(x,1) �́Ax = 1 �ɂ�����
%   ���炩�ł͂���܂���BLin �� Segel �́A���� ���E�l����2�̖��
%   �Ƃ��ďq�ׂĂ��܂��B 1�́A[0, 1] ��ɐݒ肳��A����1�� 
%   [1, lambda]��ɐݒ肳��Av(x) �� C(x) �� x = 1 �ŘA���ł��邱�Ƃ�
%   �v�����邱�Ƃɂ��Ȃ����܂��B���̉��́A���E���� v(0) = 0 �� 
%   C(lambda) = 1�𖞂������ƂɂȂ��Ă��܂��BBVP4C �́A�ړ_ x = 1��
%   �����������ۂ��A3�_���E�l���(three-point BVP)�Ƃ��Ă��̖���
%   �����܂��B
%   
%�@ ���̗�́An = 5e-2, lambda = 2, ����� �� kappa = 2,3,4,5 
%   �ɑ΂�����������܂��Bkappa ��1�̒l�ɑ΂�����́A ��
%   �̂��̂ɑ΂��鐄���Ƃ��Ďg�p����܂��B
%
%   �Q�l BVP4C, BVPSET, BVPGET, BVPINIT, DEVAL, @.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2003 The MathWorks, Inc. 
