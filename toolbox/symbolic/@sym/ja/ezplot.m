% EZPLOT �ȒP�Ȋ֐��v���b�g
% EZPLOT(f)�́A�f�t�H���g�̗̈� -2*pi < x < 2*pi �ŁA���� f=f(x) ���v��
% �b�g���܂��B
%
% EZPLOT(f, [a,b])�́Aa < x < b �� f=f(x) ���v���b�g���܂��B
%
% �A�I�ɁA�֐� f=f(x,y)���`���܂��BEZPLOT(f)�́A�f�t�H���g�̗̈� -2*pi
% < x  < 2*pi, -2*pi < y < 2*pi �ŁAf(x,y) = 0���v���b�g���܂��B
%
% EZPLOT(f, [xmin,xmax,ymin,ymax])�́Axmin < x < xmax,  ymin < y < ymax 
% �ŁAf(x,y) = 0 ���v���b�g���܂��B
% 
% EZPLOT(f, [a,b])�́Aa < x < b, a < y < b �ŁAf(x,y) = 0 ���v���b�g����
% ���Bf���A�ϐ�u,v�̊֐��ł���ꍇ�́A�̈�̏I���_a,b�́A�A���t�@�x�b�g
% ���Ƀ\�[�g����܂��B���Ƃ��΁AEZPLOT(u^2 - v^2 - 1,[-3,2,-2,3])�́A-3 
% < u < 2, -2 < v < 3 �ŁAu^2 - v^2 - 1 = 0 ���v���b�g���܂��B
%
% EZPLOT(x,y)�́A�f�t�H���g�̗̈� 0 < t < 2*pi �ŁA�p�����g���b�N�ɒ�`
% ���ꂽ���ʋȐ� x=x(t), y=y(t) ���v���b�g���܂��BEZPLOT(x,y, [tmin,tm-
% ax])�́Atmin < t < tmax �ŁAx=x(t), y=y(t)���v���b�g���܂��B
%
% EZPLOT(f, [a,b], FIG), EZPLOT(f, [xmin,xmax,ymin,ymax], FIG)�A�܂��́A
% EZPLOT(x,y, [tmin,tmax], FIG)�́Afigure �E�B���h�EFIG�Ŏw�肳�ꂽ�̈�
% �ŁA�^����ꂽ�֐����v���b�g���܂��B
%
% ���F
%     syms x y t
%     ezplot(cos(x))
%     ezplot(cos(x), [0, pi])
%     ezplot(x^2 - y^2 - 1)
%     ezplot(x^2 + y^2 - 1,[-1.25,1.25],3); axis equal
%     ezplot(1/y-log(y)+log(-1+y)+x - 1)
%     ezplot(x^3 + y^3 - 5*x*y + 1/5,[-3,3])
%     ezplot(x^3 + 2*x^2 - 3*x + 5 - y^2)
%     ezplot(sin(t),cos(t))
%     ezplot(sin(3*t)*cos(t),sin(3*t)*sin(t),[0,pi])



%   Copyright 1993-2002 The MathWorks, Inc.
