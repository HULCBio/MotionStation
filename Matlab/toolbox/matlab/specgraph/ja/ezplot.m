% EZPLOT   �ȒP�Ȋ֐��v���b�g�̎g����
% 
% EZPLOT(f) �́A�f�t�H���g�̗̈� -2*pi < x < 2*pi �ŁA���� f = f(x) ��
% �v���b�g���܂��B
%
% EZPLOT(f�A[a,b]) �́Aa < x < b �� f = f(x) ���v���b�g���܂��B
%
% �A�I�ɒ�`���ꂽ�֐� f = f(x,y) �ɑ΂��āAEZPLOT(f) �́A�f�t�H���g��
% �̈� -2*pi < x < 2*pi�A-2*pi < y < 2*pi �ŁAf(x,y) = 0 ���v���b�g���܂��B
% EZPLOT(f�A[xmin,xmax,ymin,ymax])�́Axmin < x < xmax�Aymin < y < ymax�ŁA
% f(x,y) = 0 ���v���b�g���܂��B
% EZPLOT(f�A[a,b]) �́Aa < x < b�Aa < y < b �ŁAf(x,y) = 0 ���v���b�g���܂��B
% f ���ϐ� u,v �̊֐��ł���ꍇ�́A�̈�̏I���_ a,b �́A�A���t�@�x�b�g����
% �\�[�g����܂��B���Ƃ��΁AEZPLOT('u^2 - v^2 - 1',[-3,2,-2,3]) �́A
% -3 < u < 2�A-2 < v < 3 �ŁAu^2 - v^2 - 1 = 0 ���v���b�g���܂��B
%
% EZPLOT(x,y) �́A�f�t�H���g�̗̈� 0 < t < 2*pi �ŁA�p�����g���b�N�ɒ�`
% ���ꂽ���ʃJ�[�u x = x(t)�Ay = y(t) ���v���b�g���܂��B
% EZPLOT(x,y�A[tmin,tmax]) �́Atmin < t < tmax �ŁAx = x(t)�Ay = y(t)��
% �v���b�g���܂��B
%
% EZPLOT(f�A[a,b]�AFIG)�AEZPLOT(f�A[xmin,xmax,ymin,ymax]�AFIG),
% EZPLOT(x,y�A[tmin,tmax]�AFIG)�́Afigure�E�B���h�E FIG �Ŏw�肳�ꂽ
% �̈�ŁA�^����ꂽ�֐����v���b�g���܂��B
%
% EZPLOT(AX,...) �́AGCA�܂���FIG�̑����AX�Ƀv���b�g���܂��B
%
% H = EZPLOT(...) �́A�v���b�g���ꂽ�I�u�W�F�N�g�̃n���h����H�ɏo�͂��܂��B
%
% ���:
%   f �́A��ʓI�ȕ\���ł����A@ �܂��̓C�����C���֐����g���Ďw�肷��
%   ���Ƃ��ł��܂��B
%     ezplot('cos(x)')
%     ezplot('cos(x)', [0, pi])
%     ezplot('1/y-log(y)+log(-1+y)+x - 1')
%     ezplot('x^2 - y^2 - 1')
%     ezplot('x^2 + y^2 - 1',[-1.25,1.25]); axis equal
%     ezplot('x^3 + y^3 - 5*x*y + 1/5',[-3,3])
%     ezplot('x^3 + 2*x^2 - 3*x + 5 - y^2')
%     ezplot('sin(t)','cos(t)')
%     ezplot('sin(3*t)*cos(t)','sin(3*t)*sin(t)',[0,pi])
%     ezplot('t*cos(t)','t*sin(t)',[0,4*pi])
%
%     f = inline('cos(x)+2*sin(x)');
%     ezplot(f)
%     ezplot(@humps)
%
% �Q�l�FEZCONTOUR, EZCONTOURF, EZMESH, EZMESHC, EZPLOT3,
%       EZPOLAR, EZSURF, EZSURFC, PLOT.


%   Copyright 1984-2002 The MathWorks, Inc.  
