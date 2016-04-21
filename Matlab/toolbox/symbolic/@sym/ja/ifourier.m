% IFOURIER   �t�t�[���G�ϕ��ϊ�
% f = IFOURIER(F) �́A�f�t�H���g�̓Ɨ��ϐ� w ���X�J���V���{�� F �̋t�t�[
% ���G�ϊ��ł��B�f�t�H���g�̏o�͂́Ax �̊֐��ł��B�t�t�[���G�ϊ��́Aw ��
% �֐��ɓK�p����Ax �̊֐����o�͂��܂��B���Ȃ킿�AF = F(w) => f = f(x) 
% �ł��B
% 
% F = F(x) �̏ꍇ�AIFOURIER �́At �̊֐����o�͂��܂��B���Ȃ킿�Af = f(t)
% �ł��B��`�ɂ��Af(x) = 1/(2*pi) * int(F(w)*exp(i*w*x),w,-inf,inf) ��
% �ϕ��́Aw �Ɋւ��čs���܂��B
% 
% f = IFOURIER(F, u) �́A�f�t�H���g�� x �̑���ɁAu �̊֐� f ���쐬��
% �܂��B
% 
%    IFOURIER(F,u) <=> f(u) = 1/(2*pi) * int(F(w)*exp(i*w*u,w,-inf,inf)
% 
% �����ŁAu �́A�X�J���V���{��(w �Ɋւ���ϕ�)�ł��Bf = IFOURIER(F, v, 
% u) �́A�f�t�H���g w �̑���� v �̊֐�����\������� F ���g���܂��B��
% �Ȃ킿�A
% 
%   IFOURIER(F,v,u)<=> f(u) = 1/(2*pi) * int(F(v)*exp(i*v*u, v, -inf, 
%   inf) 
% 
% v �Ɋւ���ϕ��ł��B
% 
% ���F
%  syms t u w x
%  ifourier(w*exp(-3*w)*sym('Heaviside(w)')) �́A���̏o�͂��s���܂��B 
% 
%         1/2/pi/(3-i*t)^2
%
%  ifourier(1/(1 + w^2),u) �́A���̏o�͂��s���܂��B
% 
%         1/2*exp(-u)*Heaviside(u)+1/2*exp(u)*Heaviside(-u)
%
%  ifourier(v/(1 + w^2),v,u) �́A���̏o�͂��s���܂��B  
% 
%         i/(1+w^2)*Dirac(1,-u)
%         
%  ifourier(sym('fourier(f(x),x,w)'),w,x) �́A���̏o�͂��s���܂��B 
% 
%         f(x)
%
% �Q�l�F FOURIER, ILAPLACE, IZTRANS.



%   Copyright 1993-2002 The MathWorks, Inc.
