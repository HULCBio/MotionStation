% EXPINT   �w���ϕ��֐�
% 
% Y = EXPINT(X) �́AX �̊e�v�f�ɑ΂���w���ϕ��֐��ł��B�w���ϕ��́A
% ���̂悤�ɒ�`����܂��B
%
% EXPINT(x) =  x > 0 �ɂ��āA(exp(-t)/t) dt��X����Inf�܂ł̐ϕ�
% 
% ��͓I�A�����̂��߁AEXPINT �́A���̎������ƌ������镡�f���ʏ�̈ꉿ
% �֐��ł��B
%
% �w���ϕ��֐��̂���1�̈�ʓI�Ȓ�`�́A���� X �ɑ΂��āA-Inf���� X 
% �܂ł� (exp(t)/t)dt��Cauchy�̎�l�ϕ��ł��B����́AEi(x) �ƕ\�킳��܂��B
% EXPINT(x) �� Ei(x) �̊֌W�́A���̂悤�ɂȂ�܂��B
%
% 0���傫�������� x �ɑ΂��āAEXPINT(-x+i*0) = -Ei(x) - i*pi
% 0���傫�������� x �ɑ΂��āAEi(x) = REAL(-EXPINT(-x))


%   D. L. Chen 9-29-92, CBM 6-28-94.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:04:12 $
