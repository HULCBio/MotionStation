% EZMESH   3�������b�V���̊ȒP�Ȏg����
% 
% EZMESH(f) �́Af �������񂩁A�܂���2�ϐ� 'x' �� 'y' ���g�������w�֐�
% ��\�킷�V���{���b�N�ȕ\���̂Ƃ��AMESH ���g���� f(x,y) �̃O���t��
% �v���b�g���܂��B�֐� f �́A�f�t�H���g�̗̈� -2*pi < x < 2*pi�A
% -2*pi < y < 2*pi �Ƀv���b�g����܂��B�v�Z�����O���b�h�́A������ω�
% �̑��ʂɏ]���đI������܂��B
% 
% EZMESH(f,DOMAIN) �́A�f�t�H���gDOMAIN = [-2*pi,2*pi,-2*pi,2*pi] ��
% ����ɁA�w�肵���̈�� f ���v���b�g���܂��BDOMAIN �́A4�s1��x�N�g��
% [xmin,xmax,ymin,ymax]�A�܂���(a < x < b�Aa < y < b �Ƀv���b�g���邽
% �߂�)2�s1��x�N�g�� [a,b] �ł��B
%
% f ���ϐ� u �� v(x �� y �ł͂Ȃ�)�̊֐��ł���ꍇ�A�̈�̒[�_ umin�A
% umax�Avmin�Avmax �́A�A���t�@�x�b�g���ɕ��בւ����܂��B���̂��߁A
% EZMESH('u^2 - v^3',[0,1,3,6]) �́A0 < u < 1�A3 < v < 6 �ɁAu^2 - v^3
% ���v���b�g���܂��B
% 
% EZMESH(x,y,z) �́A-2*pi < s < 2*pi and -2*pi < t < 2*pi �Ƀp�����g
% ���b�N�ȃT�[�t�F�X x = x(s,t)�Ay = y(s,t)�Az = z(s,t) ���v���b�g���܂��B
%
% EZMESH(x,y,z,[smin,smax,tmin,tmax]) �܂��� EZMESH(x,y,z,[a,b]) �́A
% �w�肵���̈���g�p���܂��B
%
% EZMESH(...,N) �́AN�sN��̃O���b�h���g���ăf�t�H���g�̗̈�� f ��
% �v���b�g���܂��BN �̃f�t�H���g�l�́A60�ł��B
%
% EZMESH(...,'circ') �́A�~�`�̈��� f ���v���b�g���܂��B
%
% EZMESH(AX,...) �́AGCA�̑����AX�Ƀv���b�g���܂��B
%
% H = EZMESH(...) �́A�v���b�g���ꂽ�I�u�W�F�N�g�̃n���h����H�ɏo�͂��܂��B
%
% ���:
%   f �́A��ʓI�ȕ\���ł����A@ �܂��̓C�����C���֐����g���Ďw�肷��
%   ���Ƃ��ł��܂��B
%    f = ['3*(1-x)^2*exp(-(x^2) - (y+1)^2)' ... 
%       '- 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2)' ... 
%       '- 1/3*exp(-(x+1)^2 - y^2)'];
%    ezmesh(f,[-pi,pi])
%    ezmesh('x*exp(-x^2 - y^2)')
%    ezmesh('x*y','circ')
%    ezmesh('real(atan(x + i*y))')
%    ezmesh('exp(-x)*cos(t)',[-4*pi,4*pi,-2,2])
%
%    ezmesh('s*cos(t)','s*sin(t)','t')
%    ezmesh('exp(-s)*cos(t)','exp(-s)*sin(t)','t',[0,8,0,4*pi])
%    ezmesh('(s-sin(s))*cos(t)','(1-cos(s))*sin(t)','s',[-2*pi,2*pi])
%
%    h = inline('x*y - x');
%    ezmesh(h)
%    ezmesh(@peaks)
%
% �Q�l�FEZPLOT, EZPLOT3, EZPOLAR, EZCONTOUR, EZCONTOURF, EZSURF, 
%       EZSURFC, EZMESHC, MESH.



%   Copyright 1984-2002 The MathWorks, Inc. 
