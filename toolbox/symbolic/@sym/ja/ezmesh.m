% EZMESH 3�����T�[�t�F�X���b�V���̊ȒP�ȃv���b�g
%
% EZMESH(f)�́Af�������񂩁A�܂��́A2�ϐ�'x'��'y'�̐��w�\����\�킷�V��
% �{���b�N�ȕ\���̂Ƃ��AMESH���g���āAf(x,y)�̃O���t���v���b�g���܂��B��
% ��f�́A�f�t�H���g�̗̈�-2*pi < x < 2*pi, -2*pi < y < 2*pi�Ƀv���b�g��
% ��܂��B�v�Z�����O���b�h�́A������ω��ʂɏ]���đI������܂��B
% 
% EZMESH(f,DOMAIN)�́A�f�t�H���gDOMAIN = [-2*pi,2*pi,-2*pi,2*pi]�̑���
% �ɁA�w�肵��DOMAIN��f���v���b�g���܂��BDOMAIN�́A4�s1��̃x�N�g��[xmin
% xmax,ymin,ymax]�A�܂��́A(a < x < b, a < y < b�Ƀv���b�g���邽�߂�)2�s
% 1��̃x�N�g��[a,b]�ł��B
%
% f���ϐ�u��v(x��y�ł͂Ȃ�)�̊֐��ł���ꍇ�A�̈�̏I���_umin, umax, vmi
% n, vmax �́A�A���t�@�x�b�g���ɕ��בւ����܂��B���̂��߁AEZMESH(u^2 -
%  v^3,[0,1,3,6]) �́A0 < u < 1, 3 < v < 6�ɁAu^2 - v^3���v���b�g���܂��B
%
% EZMESH(x,y,z)�́A-2*pi < s < 2*pi �� -2*pi < t < 2*pi�Ƀp�����g���b�N
% �ȃT�[�t�F�X x = x(s,t), y = y(s,t), z = z(s,t)���v���b�g���܂��B
%
% EZMESH(x,y,z,[smin,smax,tmin,tmax])�A�܂��́AEZMESH(x,y,z,[a,b])�́A�w
% �肵���̈���g�p���܂��B
%
% EZMESH(...,fig)�́Afigure�E�B���h�Efig�Ƀf�t�H���g�̗̈�Ńv���b�g����
% ���B
%
% EZMESH(...,'circ')�́A�̈�̒��S�t�߂ŉ~�`���f���v���b�g���܂��B
%
%
% ���F
% 
%    syms x y s t
%    f = 3*(1-x)^2*exp(-(x^2) - (y+1)^2) ... 
%       - 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2) ... 
%       - 1/3*exp(-(x+1)^2 - y^2);
%    ezmesh(f,[-pi,pi])
%    ezmesh(x*exp(-x^2 - y^2))
%    ezmesh(x*y,'circ')
%    ezmesh(real(atan(x + i*y)))
%    ezmesh(exp(-x)*cos(t),[-4*pi,4*pi,-2,2])
%
%    ezmesh(s*cos(t),s*sin(t),t)
%    ezmesh(exp(-s)*cos(t),exp(-s)*sin(t),t,[0,8,0,4*pi])
%    ezmesh((s-sin(s))*cos(t),(1-cos(s))*sin(t),s,[-2*pi,2*pi])
%
% �Q�l�F EZPLOT, EZPLOT3, EZPOLAR, EZCONTOUR, EZCONTOURF, EZMESH, 
%        EZSURFC, EZMESHC, SURF.



%   Copyright 1993-2002 The MathWorks, Inc.
