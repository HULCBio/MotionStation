% SHOCKBVP �@���́Ax = 0 �ߖT�̃V���b�N�w�������Ă��܂��B
% 
% ����́A���b�V���I����@���g���� Numerical Solution of Boundary Value 
% Problems for Ordinary Differential Equations, SIAM, Philadelphia, PA, 
% 1995 �� U. Ascher, R. Mattheij, R. Russell �Ŏ��������ł��B
%
% 0 < e << 1 �ɑ΂��āA 
%
%     e*u'' + x*u' = -e*pi^2*cos(pi*x) - pi*x*sin(pi*x)
%
% �̉��́A���E���� u(-1) = -2,u(1) = 0 �ŁA��� [-1,1]�͈̔͂ŁAx = 0 ��
% �}���ȑJ�ڑw�������܂��B
%
% ���̗��́A�A�������g���āA���܂��������߂邽�߂ɂ́A�ǂ̂��炢���
% ��肩�𐔒l�I�Ɏ��������̂ł�(e = 1e-5)�B���̗��ɑ΂��āA��͓I�ȕ�
% ���W���͓��o���ȒP�ŁA�\���o�͔��W�����g���悤�ɍ���Ă��܂��B
% 
% �Q�l�FBVP4C, BVPINIT, BVPVAL, BVPSET, BVPGET, @. 



%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $  $Date: 2004/04/28 01:49:24 $
