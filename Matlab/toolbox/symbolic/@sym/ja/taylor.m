% TAYLOR   Taylor �����W�J
% TAYLOR(f) �́Af �ɑ΂���5���� Maclaurin �������ߎ����o�͂��܂��B3��
% �p�����[�^��C�ӂ̏����ŗ^���邱�Ƃ��ł��܂��B
% 
% TAYLOR(f, n) �́A(n-1) ���� Maclaurin �������ł��B
% TAYLOR(f, a) �́A�_a�Ɋւ��� Taylor �������ߎ������߂܂��B
% TAYLOR(f, x) �́AFINDSYM(f) �̑���ɓƗ��ϐ�x���g���܂��B
%
% ��� :
% taylor(exp(-x)) �́A1-x+1/2*x^2-1/6*x^3+1/24*x^4-1/120*x^5 ���o�͂���
% ���B
% 
% taylor(log(x),6,1) �́Ax-1-1/2*(x-1)^2+1/3*(x-1)^3-1/4*(x-1)^4+....
% 1/5*(x-1)^5 ���o�͂��܂��B
% 
% taylor(sin(x),pi/2,6) �́A1-1/2*(x-1/2*pi)^2+1/24*(x-1/2*pi)^4 ���o��
% ���܂��B
% 
% taylor(x^t,3,t) �́A1+log(x)*t+1/2*log(x)^2*t^2���o�͂��܂��B
%
% �Q�l�F FINDSYM, SYMSUM.



%   Copyright 1993-2002 The MathWorks, Inc.
