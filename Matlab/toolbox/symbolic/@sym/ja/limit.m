% LIMIT   �V���{���b�N���̋Ɍ��l
% LIMIT(F, x, a) �́Ax -> a �̂Ƃ��̃V���{���b�N�� F �̋Ɍ��l���v�Z����
% ���B
% LIMIT(F, a)�́A�Ɨ��ϐ��Ƃ��� findsym(F) ���g���܂��B
% LIMIT(F) �́A�Ɍ��_�Ƃ��� a = 0���g���܂��B
% LIMIT(F, x, a, 'right')�A�܂��́ALIMIT(F, x, a, 'left')�́A�Б��Ɍ���
% �������w�肵�܂��B
%
% ��� :
%     syms x a t h;
%
%     limit(sin(x)/x) �́A1���o�͂��܂��B
%     limit((x-2)/(x^2-4),2) �́A1/4���o�͂��܂��B
%     limit((1+2*t/x)^(3*x),x,inf) �́Aexp(6*t) ���o�͂��܂��B
%     limit(1/x,x,0,'right') �́Ainf ���o�͂��܂��B
%     limit(1/x,x,0,'left') �́A-inf ���o�͂��܂��B
%     limit((sin(x+h)-sin(x))/h,h,0) �́Acos(x) ���o�͂��܂��B
%     v = [(1 + a/x)^x, exp(-x)];
%     limit(v,x,inf,'left') �́A[exp(a),  0] ���o�͂��܂��B



%   Copyright 1993-2002 The MathWorks, Inc.
