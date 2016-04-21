% FOURIER   �t�[���G�ϕ��ϊ�
% F = FOURIER(f) �́A�f�t�H���g�̓Ɨ��ϐ� x �����V���{���b�N�X�J�� f 
% �̃t�[���G�ϊ��ł��B�f�t�H���g�ł́Aw �̊֐����o�͂��܂��B
% 
% f = f(w) �Ȃ�΁AFOURIER �́At �̊֐� F = F(t) ���o�͂��܂��B��`�ɂ�
% ��A
% 
%    F(w) = int(f(x)*exp(-i*w*x),x,-inf,inf)
% 
% �ƂȂ�Ax(FINDSYM �Ō��肳���悤�� f �̃V���{���b�N�ϐ�)�Ɋւ��Đϕ�
% ���܂��B
% 
% F = FOURIER(f, v) �́A�f�t�H���g�� w �̑���ɁA�V���{���b�N v �̊֐�
% F���v�Z���܂��B
% 
%    FOURIER(f,v) <=> F(v) = int(f(x)*exp(-i*v*x),x,-inf,inf)
%
% FOURIER(f, u, v)�́A�f�t�H���g�� x �̑���ɁAu �̊֐� f ���v�Z���܂��B
% �ϕ��́Au �Ɋւ��čs���܂��B
%   
%    FOURIER(f,u,v) <=> F(v) = int(f(u)*exp(-i*v*u),u,-inf,inf)
%
% ��� :
%   syms t v w x
%   fourier(1/t) �́Ai*pi*(Heaviside(-w)-Heaviside(w)) ���o�͂��܂��B
%   fourier(exp(-x^2),x,t) �́Api^(1/2)*exp(-1/4*t^2) ���o�͂��܂��B
%   fourier(exp(-t)*sym('Heaviside(t)'),v) �́A1/(1+i*v) ���o�͂��܂��B
%   fourier(diff(sym('F(x)')),x,w) �́Ai*w*fourier(F(x),x,w) ���o�͂���
%   ���B
%
% �Q�l�F IFOURIER, LAPLACE, ZTRANS.



%   Copyright 1993-2002 The MathWorks, Inc.
