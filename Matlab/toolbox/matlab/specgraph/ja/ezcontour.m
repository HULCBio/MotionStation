% EZCONTOUR   �R���^�[�̊ȒP�ȃv���b�g
% 
% EZCONTOUR(f) �́Af �������񂩁A�܂���2�ϐ��A'x' �� 'y' ���g���Đ��w
% �֐���\�킷�V���{���b�N�ȕ\���̂Ƃ��ACONTOUR ���g���� f(x,y) ��
% �R���^�[���C�����v���b�g���܂��B
% �֐� f �́A�f�t�H���g�̗̈� -2*pi < x < 2*pi�A-2*pi < y < 2*pi ��
% �v���b�g����܂��B
% �v�Z�����O���b�h�́A������ω��̑��ʂɏ]���đI������܂��B
%
% EZCONTOUR(f,DOMAIN) �́A�f�t�H���g DOMAIN = [-2*pi,2*pi,-2*pi,2*pi] 
% �̑���ɁA�w�肵���̈� DOMAIN ��� f ���v���b�g���܂��BDOMAIN �́A
% 4�s1��x�N�g�� [xmin,xmax,ymin,ymax]�A�܂���(a < x < b�Aa < y < b ��
% �v���b�g���邽�߂�)2�s1��x�N�g�� [a,b] �ł��B
%
% f ���ϐ� u �� v(x �� y �ł͂Ȃ�)�̊֐��ł���ꍇ�A�̈�̏I���_umin�A
% umax�Avmin�Avmax �́A�A���t�@�x�b�g���ɕ��בւ����܂��B���̂��߁A
% EZCONTOUR('u^2-v^3',[0,1],[3,6]) �́A0 < u < 1�A3 < v < 6 �ŁA
% u^2 - v^3 �ɑ΂��ăR���^�[���C�����v���b�g���܂��B
%
% EZCONTOUR(...,N) �́AN�sN��̃O���b�h���g���ăf�t�H���g�̗̈�� f ��
% �v���b�g���܂��BN �̃f�t�H���g�l�́A60�ł��B
%
% EZCONTOUR(AX,...) �́AGCA�̑����AX�Ƀv���b�g���܂��B
%
% H = EZCONTOUR(...) �́A�R���^�[�I�u�W�F�N�g�̃n���h����H�ɏo�͂��܂��B
%
% ���:
%    f �́A��ʓI�ȕ\���ł����A@ ��A�C�����C���֐����g���Ďw�肷��
%    ���Ƃ��ł��܂��B
%    f = ['3*(1-x)^2*exp(-(x^2) - (y+1)^2)' ... 
%       '- 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2)' ... 
%       '- 1/3*exp(-(x+1)^2 - y^2)'];
%    ezcontour(f,[-pi,pi])
%    ezcontour('sin(sqrt(x^2+y^2))/sqrt(x^2+y^2)',[-6*pi,6*pi])
%    ezcontour('x*exp(-x^2 - y^2)')
%    ezcontour('-3*z/(1 + t^2 - z^2)',[-4,4],120)
%    ezcontour('sin(u)*sin(v)',[-2*pi,2*pi])
%
%    h = inline('x*y - x');
%    ezcontour(h)
%    ezcontour(@peaks)
%
% �Q�l�FEZPLOT, EZPLOT3, EZPOLAR, EZCONTOURF, EZSURF, EZMESH,
%       EZSURFC, EZMESHC, CONTOUR.


%   Copyright 1984-2002 The MathWorks, Inc. 
