% EZSURFC   surf��contour�̑g���킹�̊ȒP�Ȏg����
% 
% EZSURFC(f) �́Af �������񂩁A�܂���2�̃V���{���b�N�ϐ� 'x' �� 'y' ��
% �g�������w�֐���\�킷�V���{���b�N�ȕ\���̂Ƃ��ASURFC ���g���� f(x,y) 
% �̃O���t���v���b�g���܂��B
% �֐� f �́A�f�t�H���g�̗̈� -2*pi < x < 2*pi�A-2*pi < y < 2*pi ��
% �v���b�g����܂��B
% �v�Z�����O���b�h�́A������ω��̑��ʂɏ]���đI������܂��B
% 
% EZSURFC(f,DOMAIN) �́A�f�t�H�� �gDOMAIN = [-2*pi,2*pi,-2*pi,2*pi] ��
% ����ɁA�w�肵���̈�� f ���v���b�g���܂��BDOMAIN �́A4�s1��x�N�g��
% [xmin,xmax,ymin,ymax]�A�܂���(a < x < b�Aa < y < b �Ƀv���b�g���邽��
% ��)2�s1��x�N�g�� [a,b] �ł��B
%
% f ���ϐ� u �� v(x �� y �ł͂Ȃ�)�̊֐��ł���ꍇ�A�A�̈�̒[�_umin�A
% umax�Avmin�Avmax�́A�A���t�@�x�b�g���ɕ��בւ����܂��B���̂��߁A
% EZSURFC('u^2 - v^3',[0,1,3,6]) �́A0 < u < 1�A3 < v < 6 �� u^2 - v^3 
% ���v���b�g���܂��B
%
% EZSURFC(x,y,z) �́A-2*pi < s < 2*pi �� -2*pi < t < 2*pi �Ƀp�����g
% ���b�N�ȃT�[�t�F�X x = x(s,t)�Ay = y(s,t)�Az = z(s,t) ���v���b�g���܂��B
%
% EZSURFC(x,y,z,[smin,smax,tmin,tmax] )�܂��� EZSURFC(x,y,z,[a,b]) �́A
% �w�肵���̈���g�p���܂��B
%
% EZSURFC(...,N) �́AN�sN��̃O���b�h���g���ăf�t�H���g�̗̈�� f ��
% �v���b�g���܂��BN �̃f�t�H���g�l�́A60�ł��B
%
% EZSURFC(...,'circ') �́A�̈��ɉ~�`�� f ���v���b�g���܂��B
%
% EZSURFC(AX,...) �́AGCA�̑����AX�Ƀv���b�g���܂��B
%
% H = EZSURFC(...) �́A�v���b�g���ꂽ�I�u�W�F�N�g�̃n���h����H�ɏo�͂��܂��B
%
% ���:
%   f �́A��ʓI�ȕ\���ł����A@ �܂��̓C�����C���֐����g���Ďw�肷��
%   ���Ƃ��ł��܂��B
%    f = ['3*(1-x)^2*exp(-(x^2) - (y+1)^2)' ... 
%       '- 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2)' ... 
%       '- 1/3*exp(-(x+1)^2 - y^2)'];
%    ezsurfc(f,[-pi,pi])
%    ezsurfc('x*exp(-x^2 - y^2)')
%    ezsurfc('sin(u)*sin(v)')
%    ezsurfc('imag(atan(x + i*y))',[-2,2])
%    ezsurfc('y/(1 + x^2 + y^2)',[-5,5,-2*pi,2*pi])
%
%    ezsurfc('(s-sin(s))*cos(t)','(1-cos(s))*sin(t)','s',[-2*pi,2*pi])
%
%    h = inline('x*y - x');
%    ezsurfc(h)
%    ezsurfc(@peaks)
%
% �Q�l�FEZPLOT, EZPLOT3, EZPOLAR, EZCONTOUR, EZCONTOURF, EZMESH, 
%       EZSURF, EZMESHC, SURFC.


%   Copyright 1984-2002 The MathWorks, Inc. 
