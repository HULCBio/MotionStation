% EZPLOT3  3�����p�����g���b�N�Ȑ��̊ȒP�ȃv���b�g
% EZPLOT3(x, y, z)�́A�f�t�H���g�̗̈�0 < t < 2*pi�ɁA��ԓI�ȋȐ� x = x
% (t), y = y(t), z = z(t)���v���b�g���܂��B
%
% EZPLOT3(x, y, z, [tmin, tmax]) �́Atmin < t < tmax�ɁA�Ȑ� x = x(t), y
% = y(t), z = z(t) ���v���b�g���܂��B
%
% EZPLOT3(x, y, z, 'animate')�A�܂��́AEZPLOT(x, y, z, [tminm, tmax], 
% 'animate') �́A�Ȑ��̃A�j���[�V�����������O�Ղ��쐬���܂��B
%   
% ���F
% 
%   syms t
%   ezplot3(sin(t),cos(t),t)
%   ezplot3(sin(t),cos(t),t,[0,6*pi])
%   ezplot3(sin(3*t)*cos(t),sin(3*t)*sin(t),t,[0,12],'animate')
%   ezplot3((4+cos(1.5*t))*cos(t),(2+cos(1.5*t))*sin(t),....
%   sin(1.5*t),[0,4*pi])
%
% �Q�l�FEZPLOT, EZSURF, EZPOLAR, PLOT, PLOT3



%   Copyright 1993-2002 The MathWorks, Inc.
