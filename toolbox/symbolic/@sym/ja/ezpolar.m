% EZPOLAR �ɍ��W�̊ȒP�ȃv���b�g
% EZPOLAR(f) �́A�f�t�H���g�̗̈� 0 < theta < 2*pi�ɁA�ɋȐ� rho = f(the
% ta)���v���b�g���܂��B
%
% EZPOLAR(f, [a,b])�́Aa < theta < b �ɑ΂��āAf ���v���b�g���܂��B
%
% ���
%       syms t
%       ezpolar(1 + cos(t))
%       ezpolar(cos(2*t))
%       ezpolar(sin(tan(t)))
%       ezpolar(sin(3*t))
%       ezpolar(cos(5*t))
%       ezpolar(sin(2*t)*cos(3*t),[0,pi])
%       ezpolar(1 + 2*sin(t/2))
%       ezpolar(1 - 2*sin(3*t))
%       ezpolar(sin(t)/t, [-6*pi,6*pi])
%
%       r = 100/(100+(t-1/2*pi)^8)*(2-sin(7*t)-1/2*cos(30*t));
%       ezpolar(r,[-pi/2,3*pi/2])
%
% �Q�l�F EZPLOT3, EZPLOT, EZSURF, PLOT, PLOT3, POLAR



%   Copyright 1993-2002 The MathWorks, Inc.
