% EZCONTOURF �h��Ԃ����R���^�[�̊ȒP�ȃv���b�g
%
% EZCONTOURF(f)�́Af�������񂩁A�܂��́A2�ϐ�'x'��'y'�̐��w�֐���\�킷
% �V���{���b�N�ȕ\���̂Ƃ��ACONTOURF���g���āAf(x,y)�̃R���^�[���C�����v
% ���b�g���܂��B�֐�f�́A�f�t�H���g�̗̈� -2*pi < x < 2*pi, -2*pi < y < 
% 2*pi�Ƀv���b�g����܂��B�v�Z�����O���b�h�́A������ω��ʂɏ]���đI��
% ����܂��B
%
% EZCONTOURF(f,DOMAIN)�́A�f�t�H���gDOMAIN = [-2*pi,2*pi,-2*pi,2*pi]�̑�
% ���ɁA�w�肵��DOMAIN��f���v���b�g���܂��BDOMAIN�́A4�s1��̃x�N�g��
% [xmin,xmax,ymin,ymax]�A�܂��́A(a < x < b, a < y < b�Ƀv���b�g���邽��
% ��)1�s2��x�N�g��[a,b]�ł��B
%
% f���ϐ�u��v(x��y�ł͂Ȃ�)�̊֐��̏ꍇ�A�̈�̏I���_umin, umax, vmin, 
% vmax �́A�A���t�@�x�b�g���ɕ��בւ����܂��B���̂��߁AEZCONTOURF(u^2-
%  v^3,[0,1],[3,6]) �́A0 < u < 1, 3 < v < 6�ŁAu^2 - v^3�ɑ΂��ăR���^
% �[���C�����v���b�g���܂��B
%
% EZCONTOURF(...,fig)�́Afigure�E�B���h�Efig�Ƀf�t�H���g�̗̈�Ńv���b�g
% ���܂��B
%
% ���F
%    f = 3*(1-x)^2*exp(-(x^2) - (y+1)^2) ... 
%       - 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2) ... 
%       - 1/3*exp(-(x+1)^2 - y^2);
%    ezcontourf(f,[-pi,pi])
%    ezcontourf(sin(sqrt(x^2+y^2))/sqrt(x^2+y^2),[-6*pi,6*pi])
%    ezcontourf(x*exp(-x^2 - y^2))
%    ezcontourf(-3*z/(1 + t^2 - z^2),[-4,4],120)
%    ezcontourf(sin(u)*sin(v),[-2*pi,2*pi])
%
% �Q�l�F EZPLOT, EZPLOT3, EZPOLAR, EZCONTOURF, EZSURF, EZMESH,
%        EZSURFC, EZMESHC, CONTOURF.



%   Copyright 1993-2002 The MathWorks, Inc.
