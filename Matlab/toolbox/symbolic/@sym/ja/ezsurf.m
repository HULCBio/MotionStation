% EZSURF �T�[�t�F�X�̊ȒP�ȃv���b�g
% EZSURF(f) �́Af �������񂩁A�܂��́A2�̃V���{���b�N�ϐ� 'x' �� 'y' 
% �̐��w�֐���\�킷�V���{���b�N�ȕ\���̂Ƃ��ASURF ���g���āAf(x,y) �̃O
% ���t���v���b�g���܂��B
% �֐� f �́A�f�t�H���g�̗̈� -2*pi < x < 2*pi, -2*pi < y < 2*pi �Ƀv��
% �b�g����܂��B�v�Z�����O���b�h�́A������ω��ʂɏ]���đI������܂��B
% 
% EZSURF(f, DOMAIN) �́A�f�t�H���g DOMAIN = [-2*pi, 2*pi, -2*pi, 2*pi] 
% �̑���ɁA�w�肵�� DOMAIN �� f ���v���b�g���܂��BDOMAIN �́A4�s1���
% �x�N�g�� [xmin, xmax, ymin, ymax]�A�܂��́A(a < x < b, a < y < b�Ƀv��
% �b�g���邽�߂�)2�s1��̃x�N�g��[a, b]�ł��B
%
% f ���ϐ� u �� v (x �� y �ł͂Ȃ�)�̊֐��ł���ꍇ�A�̈�̏I���_ umin, 
% umax, vmin, vmax �́A�A���t�@�x�b�g���ɕ��בւ����܂��B���̂��߁AEZS
% URF(u^2, - v^3, [0, 1, 3, 6])�́A0 < u < 1, 3 < v < 6 �� u^2 - v^3 ��
% �v���b�g���܂��B
%
% EZSURF(x, y, z)�́A-2*pi < s < 2*pi �� -2*pi < t < 2*pi�ɁA�p�����g��
% �b�N�ȃT�[�t�F�X x = x(s,t), y = y(s,t), z = z(s,t) ���v���b�g���܂��B
% 
% EZSURF(x, y, z, [smin, smax, tmin, tmax])�A�܂��́AEZSURF(x, y, ...
% z, [a,b])�́A�w�肵���̈���g�p���܂��B
%
% EZSURF(..., fig)�́Afigure �E�B���h�E fig �Ƀf�t�H���g�̗̈�Ńv���b�g
% ���܂��B
%
% EZSURF(..., 'circ') �́A�̈���̉~�`��� f ���v���b�g���܂��B
%
% ���F
%    syms x y s t
%    f = 3*(1-x)^2*exp(-(x^2) - (y+1)^2) ... 
%       - 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2) ... 
%       - 1/3*exp(-(x+1)^2 - y^2);
%    ezsurf(f,[-pi,pi])
%    ezsurf(sin(sqrt(x^2+y^2))/sqrt(x^2+y^2),[-6*pi,6*pi])
%    ezsurf(x*exp(-x^2 - y^2))
%    ezsurf(x*(y^2)/(x^2 + y^4))
%    ezsurf(x*y,'circ')
%    ezsurf(real(atan(x + i*y)))
%    ezsurf(exp(-x)*cos(t),[-4*pi,4*pi,-2,2])
%    ezsurf(s*cos(t),s*sin(t),t)
%    ezsurf(s*cos(t),s*sin(t),s)
%    ezsurf(exp(-s)*cos(t),exp(-s)*sin(t),t,[0,8,0,4*pi])
%    ezsurf(cos(s)*cos(t),cos(s)*sin(t),sin(s),[0,pi/2,0,3*pi/2])
%    ezsurf((s-sin(s))*cos(t),(1-cos(s))*sin(t),s,[-2*pi,2*pi])
%    ezsurf((1-s)*(3+cos(t))*cos(4*pi*s), (1-s)*(3+cos(t))*....
%    sin(4*pi*s), 3*s + (1 - s)*sin(t), [0,2*pi/3,0,12] )
%
% �Q�l�F EZPLOT, EZPLOT3, EZPOLAR, EZCONTOUR, EZCONTOURF, EZMESH, 
%        EZSURFC, EZMESHC, SURF.



%   Copyright 1993-2002 The MathWorks, Inc.
