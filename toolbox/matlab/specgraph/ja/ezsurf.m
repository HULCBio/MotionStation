% EZSURF   3�����J���[�T�[�t�F�X�̊ȒP�Ȏg����
% 
% EZSURF(f) �́Af �������񂩁A�܂���2�̃V���{���b�N�ϐ� 'x' �� 'y' 
% ���g�������w�֐���\�킷�V���{���b�N�ȕ\���̂Ƃ��ASURF ���g���� 
% f(x,y) �̃O���t���v���b�g���܂��B
% �֐� f �́A�f�t�H���g�̗̈� -2*pi < x < 2*pi�A-2*pi < y < 2*pi ��
% �v���b�g����܂��B
% �v�Z�����O���b�h�́A������ω��̑��ʂɏ]���đI������܂��B
% 
% EZSURF(f,DOMAIN) �́A�f�t�H���g DOMAIN = [-2*pi,2*pi,-2*pi,2*pi] ��
% ����ɁA�w�肵���̈�� f ���v���b�g���܂��BDOMAIN �́A4�s1��x�N�g��
% [xmin,xmax,ymin,ymax]�A�܂���(a < x < b�Aa < y < b �Ƀv���b�g���邽��
% ��)2�s1��x�N�g�� [a,b] �ł��B
%
% f ���ϐ� u �� v(x �� y �ł͂Ȃ�)�̊֐��ł���ꍇ�A�̈�̒[�_umin�A
% umax�Avmin�Avmax�́A�A���t�@�x�b�g���ɕ��בւ����܂��B���̂��߁A
% EZSURF('u^2 - v^3',[0,1,3,6]) �́A0 < u < 1�A3 < v < 6 �� u^2 - v^3
% ���v���b�g���܂��B
%
% EZSURF(x,y,z) �́A-2*pi < s < 2*pi �� -2*pi < t < 2*pi�ɁA�p�����g
% ���b�N�ȃT�[�t�F�X x = x(s,t)�Ay = y(s,t)�Az = z(s,t) ���v���b�g���܂��B
%
% EZSURF(x,y,z,[smin,smax,tmin,tmax]) �܂��� EZSURF(x,y,z,[a,b]) �́A
% �w�肵���̈���g�p���܂��B
%
% EZSURF(...,N) �́AN�sN��̃O���b�h���g���āA�f�t�H���g�̗̈�� f ��
% �v���b�g���܂��BN �̃f�t�H���g�l�́A60�ł��B
%
% EZSURF(...,'circ') �́A�̈�ɉ~�`��f���v���b�g���܂��B
%
% EZSURF(AX,...) �́AGCA�̑����AX�Ƀv���b�g���܂��B
%
% H = EZSURF(...) ��surface�I�u�W�F�N�g�̃n���h����H�ɏo�͂��܂��B
%
% ���:
%   f �́A��ʓI�ȕ\���ł����A@ �܂��̓C�����C���֐����g���Ďw�肷��
%   ���Ƃ��ł��܂��B
%    f = ['3*(1-x)^2*exp(-(x^2) - (y+1)^2)' ... 
%       '- 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2)' ... 
%       '- 1/3*exp(-(x+1)^2 - y^2)'];
%    ezsurf(f,[-pi,pi])
%    ezsurf('sin(sqrt(x^2+y^2))/sqrt(x^2+y^2)',[-6*pi,6*pi])
%    ezsurf('x*exp(-x^2 - y^2)')
%    ezsurf('x*(y^2)/(x^2 + y^4)')
%    ezsurf('x*y','circ')
%    ezsurf('real(atan(x + i*y))')
%    ezsurf('exp(-x)*cos(t)',[-4*pi,4*pi,-2,2])
%
%    ezsurf('s*cos(t)','s*sin(t)','t')
%    ezsurf('s*cos(t)','s*sin(t)','s')
%    ezsurf('exp(-s)*cos(t)','exp(-s)*sin(t)','t',[0,8,0,4*pi])
%    ezsurf('cos(s)*cos(t)','cos(s)*sin(t)','sin(s)',[0,pi/2,0,3*pi/2])
%    ezsurf('(s-sin(s))*cos(t)','(1-cos(s))*sin(t)','s',[-2*pi,2*pi])
%    ezsurf('(1-s)*(3+cos(t))*cos(4*pi*s)', '(1-s)*(3+cos(t))*....
%    sin(4*pi*s)', '3*s + (1 - s)*sin(t)', [0,2*pi/3,0,12] )
%
%    h = inline('x*y - x');
%    ezsurf(h)
%    ezsurf(@peaks)
%
% �Q�l�FEZPLOT, EZPLOT3, EZPOLAR, EZCONTOUR, EZCONTOURF, EZMESH, 
%       EZSURFC, EZMESHC, SURF.


%   Copyright 1984-2002 The MathWorks, Inc. 
