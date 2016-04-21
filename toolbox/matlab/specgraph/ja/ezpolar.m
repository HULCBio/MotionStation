% EZPOLAR   �ɍ��W�̊ȒP�ȃv���b�g
% 
% EZPOLAR(f) �́A�f�t�H���g�̗̈� 0 < theta < 2*pi �ɁA�Ɍ`���ɂ��Ȑ�
% rho = f(theta) ���v���b�g���܂��B
%
% EZPOLAR(f,[a,b]) �́Aa < theta < b �ɑ΂��� f ���v���b�g���܂��B
%
% EZPOLAR(AX,...) �́AGCA�̑����AX�Ƀv���b�g���܂��B
%
% H = EZPOLAR(...) �́A�v���b�g���ꂽ�I�u�W�F�N�g�̃n���h����H�ɏo�͂��܂��B
%
% ���
%   f �́A��ʓI�ȕ\���ł����A@ �܂��̓C�����C���֐����g���Ďw�肷��
%   ���Ƃ��ł��܂��B
%       ezpolar('1 + cos(t)')
%       ezpolar('cos(2*t)')
%       ezpolar('sin(tan(t))')
%       ezpolar('sin(3*t)')
%       ezpolar('cos(5*t)')
%       ezpolar('sin(2*t)*cos(3*t)',[0,pi])
%       ezpolar('1 + 2*sin(t/2)')
%       ezpolar('1 - 2*sin(3*t)')
%       ezpolar('sin(t)/t', [-6*pi,6*pi])
%
%       r = '100/(100+(t-1/2*pi)^8)*(2-sin(7*t)-1/2*cos(30*t))';
%       ezpolar(r,[-pi/2,3*pi/2])
%
%       h = inline('log(gamma(x+1))');
%       ezpolar(h)
%       ezpolar(@cot,[0,pi])
%
% �Q�l�F EZPLOT3, EZPLOT, EZSURF, PLOT, PLOT3, POLAR


%   Copyright 1984-2002 The MathWorks, Inc. 
