% COMPOSE   �֐��̍���
% COMPOSE(f,g)�́Af(g(y))���o�͂��܂��B�����ŁAf = f(x)��g = g(y)�ł��Bx
% ��FINDSYM�Œ�`�����悤��f�̃V���{���b�N�ϐ��ŁAy��FINDSYM�Œ�`����
% ��悤��g�̃V���{���b�N�ϐ��ł��B
%
% COMPOSE(f,g,z)�́Af(g(z))���o�͂��܂��B�����ŁAf = f(x)��g = g(y)�ł��B
% x��y �́AFINDSYM�Œ�`�����悤��f��g�̃V���{���b�N�ϐ��ł��A
%
% COMPOSE(f,g,x,z)�́Af(g(z))���o�͂��Ax��f�ɑ΂���Ɨ��ϐ��Ƃ��܂��B��
% �܂�Af = cos(x/t)�Ȃ�΁ACOMPOSE(f,g,x,z)�́Acos(g(z)/t)���o�͂��܂��B
% ����ACOMPOSE(f,g,t,z)�́Acos(x/g(z))���o�͂��܂��B
%  
% COMPOSE(f,g,x,y,z)�́Af(g(z))���o�͂��Ax��y�����ꂼ��f��g�ɑ΂���Ɨ�
% �ϐ��Ƃ��܂��Bf = cos(x/t)��g = sin(y/u)�ɑ΂��āACOMPOSE(f,g,x,y,z)�́A
% cos(sin(z/u)/t)���o�͂��A����ACOMPOSE(f,g,x,u,z)�́Acos(sin(y/z)/t)��
% �o�͂��܂��B
% 
% ���:
% 
%  syms x y z t u;
%  f = 1/(1 + x^2); g = sin(y); h = x^t; p = exp(-y/u);
%  compose(f,g)�́A1/(1+sin(y)^2)���o�͂��܂��B 
%  compose(f,g,t)�́A1/(1+sin(t)^2)���o�͂��܂��B
%  compose(h,g,x,z)�́Asin(z)^t���o�͂��܂��B
%  compose(h,g,t,z)�́Ax^sin(z)���o�͂��܂��B
%  compose(h,p,x,y,z)�́Aexp(-z/u)^t���o�͂��܂��B 
%  compose(h,p,t,u,z)�́Ax^exp(-y/z)���o�͂��܂��B 
%
% �Q�l   FINVERSE, FINDSYM, SUBS.



%   Copyright 1993-2002 The MathWorks, Inc.
