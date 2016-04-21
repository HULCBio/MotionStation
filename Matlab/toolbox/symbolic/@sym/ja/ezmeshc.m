% EZMESHC ���b�V���ƃR���^�[�̑g���킹�̊ȒP�ȃv���b�g
%
% EZMESHC(f)�́Af�������񂩁A�܂��́A2�̃V���{���b�N�ϐ�'x'��'y'�̐��w
% �\����\�킷�V���{���b�N�\���̂Ƃ��AMESHC���g���āAf(x,y)�̃O���t���v
% ���b�g���܂��B�֐�f �́A�f�t�H���g�̗̈�-2*pi < x < 2*pi, -2*pi < y < 
% 2*pi�Ƀv���b�g����܂��B�v�Z�����O���b�h�́A������ω��ʂɏ]���đI��
% ����܂��B
% 
% EZMESHC(f,DOMAIN)�́A�f�t�H���gDOMAIN = [-2*pi,2*pi,-2*pi,2*pi]�̑��
% ��ɁA�w�肵��DOMAIN��f���v���b�g���܂��BDOMAIN�́A4�s1��̃x�N�g��[xm
% in,xmax,ymin,ymax]�A�܂��́A(a < x < b, a < y < b�Ƀv���b�g���邽�߂�)
% 2�s1��̃x�N�g��[a,b]�ł��B
%
% f���ϐ�u��v(x��y�ł͂Ȃ�)�̊֐��ł���ꍇ�A�̈�̏I���_umin, umax, 
% vmin, vmax �́A�A���t�@�x�b�g���ɕ��בւ����܂��B���̂��߁AEZMESHC
% (u^2 - v^3,[0,1,3,6]) �́A0 < u < 1, 3 < v < 6�� u^2 - v^3���v���b�g
% ���܂��B
%
% EZMESHC(x,y,z)�́A-2*pi < s < 2*pi and -2*pi < t < 2*pi�Ńp�����g���b
% �N�ȃT�[�t�F�Xx = x(s,t), y = y(s,t), z = z(s,t)���v���b�g���܂��B
%
% EZMESHC(x,y,z,[smin,smax,tmin,tmax])�A�܂��́AEZMESHC(x,y,z,[a,b])�́A
% �w�肵���̈���g�p���܂��B
%
% EZMESHC(...,fig)�́Afigure�E�B���h�Efig�Ƀf�t�H���g�̗̈�Ńv���b�g��
% �܂��B
%
% EZMESHC(...,'circ')�́A�̈��ɉ~�`��f���v���b�g���܂��B
%
% ���F
% 
%    syms x y s t
%    f = 3*(1-x)^2*exp(-(x^2) - (y+1)^2) ... 
%       - 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2) ... 
%       - 1/3*exp(-(x+1)^2 - y^2);
%    ezmeshc(f,[-pi,pi])
%    ezmeshc(x*exp(-x^2 - y^2))
%    ezmeshc(sin(u)*sin(v))
%    ezmeshc(imag(atan(x + i*y)),[-2,2])
%    ezmeshc(y/(1 + x^2 + y^2),[-5,5,-2*pi,2*pi])
%
%    ezmeshc((s-sin(s))*cos(t),(1-cos(s))*sin(t),s,[-2*pi,2*pi])
%
% �Q�l�F EZPLOT, EZPLOT3, EZPOLAR, EZCONTOUR, EZCONTOURF, EZMESH, 
%        EZSURFC, EZMESHC, SURF.


%   Copyright 1993-2002 The MathWorks, Inc.
