% EZCONTOURF   �h��Ԃ����R���^�[�̊ȒP�ȃv���b�g
% 
% EZCONTOURF(f) �́Af �������񂩁A�܂���2�ϐ� 'x' �� 'y' ���g�������w
% �֐���\�킷�V���{���b�N�ȕ\���̂Ƃ��ACONTOURF ���g���� f(x,y) ��
% �R���^�[���C�����v���b�g���܂��B
% �֐� f �́A�f�t�H���g�̗̈� -2*pi < x < 2*pi�A-2*pi < y < 2*pi ��
% �v���b�g����܂��B�v�Z�����O���b�h�́A������ω��̑��ʂɏ]���đI��
% ����܂��B
% 
% EZCONTOURF(f,DOMAIN) �́A�f�t�H���g DOMAIN = [-2*pi,2*pi,-2*pi,2*pi]
% �̑���ɁA�w�肵���̈� DOMAIN ��� f ���v���b�g���܂��BDOMAIN �́A
% 4�s1��x�N�g�� [xmin,xmax,ymin,ymax]�A�܂���(a < x < b�Aa < y < b ��
% �v���b�g���邽�߂�)2�s1��x�N�g�� [a,b] �ł��B
%
% f ���ϐ� u �� v(x �� y �ł͂Ȃ�)�̊֐��ł���ꍇ�A�̈�̒[�_umin�A
% umax�Avmin�Avmax �́A�A���t�@�x�b�g���ɕ��בւ����܂��B���̂��߁A
% EZCONTOURF('u^2- v^3',[0,1],[3,6]) �́A0 < u < 1�A3 < v < 6 �ŁA
% u^2 - v^3 �ɑ΂��ăR���^�[���C�����v���b�g���܂��B
%
% EZCONTOURF(...,N) �́AN�sN��̃O���b�h���g���ăf�t�H���g�̗̈�� f ��
% �v���b�g���܂��BN �̃f�t�H���g�l�́A60�ł��B
%
% EZCONTOURF(AX,...) �́AGCA�̑����AX�Ƀv���b�g���܂��B
%
% H = EZCONTOURF(...) �́A�R���^�[�I�u�W�F�N�g�̃n���h����H�ɏo�͂��܂��B
%
% ���:
%    f �́A��ʓI�ȕ\���ł����A@ ��A�C�����C���֐����g���Ďw�肷��
%    ���Ƃ��ł��܂��B
%    f = ['3*(1-x)^2*exp(-(x^2) - (y+1)^2)' ... 
%       '- 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2)' ... 
%       '- 1/3*exp(-(x+1)^2 - y^2)'];
%    ezcontourf(f,[-pi,pi])
%    ezcontourf('sin(sqrt(x^2+y^2))/sqrt(x^2+y^2)',[-6*pi,6*pi])
%    ezcontourf('x*exp(-x^2 - y^2)')
%    ezcontourf('-3*z/(1 + t^2 - z^2)',[-4,4],120)
%    ezcontourf('sin(u)*sin(v)',[-2*pi,2*pi])
%
%    h = inline('x*y - x');
%    ezcontourf(h)
%    ezcontourf(@peaks)
%
% �Q�l�FEZPLOT, EZPLOT3, EZPOLAR, EZCONTOUR, EZSURF, EZMESH,
%       EZSURFC, EZMESHC, CONTOURF.


%   Copyright 1984-2002 The MathWorks, Inc. 
