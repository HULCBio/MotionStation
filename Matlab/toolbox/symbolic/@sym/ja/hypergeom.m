% HYPERGEOM  ��ʑo�Ȑ��􉽊֐�
% HYPERGEIM(N, D, Z)�́ABarnes �̈�ʒ��􉽊֐��Ƃ��Ēm���Aj = lenght
% (N) �ł��Bk = length(D) �̂Ƃ� jFk �Ƃ��Ď������􉽊֐� F(N, D, Z) 
% ���쐬���܂��B�X�J���[ a, b, c �ɑ΂��āAHYPERGEOM([a, b], c, z)�́A�K
% �E�X���􉽊֐� 2F1(a, b;c;z) �ƂȂ�܂��B
% 
% �`���I�Ȃׂ������ɂ���`�́A���̂悤�ɂȂ�܂��B
%  
%     hypergeom(N, D, z) = sum(k=0:inf, (C(N,k)/C(D,k))*z^k/k!) 
%   
% �����ŁA C(V, k) = prod(i=1:length(V), gamma(V(i)+k)/gamma(V(i))) �ł��B
% �͂��߂�2�̈����̂ǂ��炩�́A�P�֐���]������W���p�����[�^�𓾂邽
% �߂̃x�N�g���ɂȂ�܂��B3�Ԗڂ̈������x�N�g���̏ꍇ�A�֐��͓_�Ƃ��ĕ]
% ������܂��B���ׂĂ̈��������l�̏ꍇ�A���ʂ͐��l�ɂȂ�A���ׂĂ̈�����
% �V���{���b�N���̏ꍇ�A���ʂ̓V���{���b�N���ɂȂ�܂��B
% 
% Abramowitz and Stegun, Handbook of Mathematical Functions, chapter 15 
% ���Q�Ƃ��Ă��������B
%
% ���F
%    syms a z
%    hypergeom([],[],z) �́Aexp(z)  ���o�͂��܂��B
%    hypergeom(1,[],z) �́A-1/(-1+z) ���o�͂��܂��B
%    hypergeom(1,2,z) �́A(exp(z)-1)/z ���o�͂��܂��B
%    hypergeom([1,2],[2,3],z) �́A-2*(-exp(z)+1+z)/z^2 ���o�͂��܂��B
%    hypergeom(a,[],z) �́A(1-z)^(-a) ���o�͂��܂��B
%    hypergeom([],1,-z^2/4) �́A besselj(0,z) ���o�͂��܂��B
%    hypergeom([-n, n],1/2,(1-z)/2) �́AT(n,z) ���o�͂��܂��B�����ŁA
%    T(n,z) = expand(cos(n*acos(z))) �́An-���� �V�r�V�F�t�������ł��B



%   Copyright 1993-2002 The MathWorks, Inc.
