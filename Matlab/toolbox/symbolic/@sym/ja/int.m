% INT   �ϕ�
% INT(S) �́AFINDSYM �Œ�`�����悤�ȃV���{���b�N�ϐ��ɂ��āAS �̕s
% ��ϕ����o�͂��܂��BS �́A�V���{���b�N�I�u�W�F�N�g(�s��܂��̓X�J��)��
% ���BS ���萔�Ȃ�΁A�ϕ��́A'x' �ɂ��Čv�Z����܂��B
% 
% INT(S, v) �́Av �ɂ��� S �̕s��ϕ����o�͂��܂��Bv �́A�X�J���V���{
% ���b�N�I�u�W�F�N�g�ł��B
% INT(S, a, b) �́A�V���{���b�N�ϐ��ɂ��āAa ���� b �܂ł� S �̒�ϕ�
% ���o�͂��܂��Ba �� b �́A�{���x�̃X�J���A�܂��́A�V���{���b�N�ȃX�J��
% �ł��B
% INT(S, v, a, b) �́Av �ɂ��āAa ���� b �܂ł� S �̒�ϕ����o�͂��܂��B
%
% ��� :
%     syms x x1 alpha u t;
%     A = [cos(x*t),sin(x*t);-sin(x*t),cos(x*t)];
%     int(1/(1+x^2)) �́Aatan(x) ���o�͂��܂��B
%     int(sin(alpha*u),alpha) �́A-cos(alpha*u)/u ���o�͂��܂��B
%     int(besselj(1,x),x) �́A-besselj(0,x) ���o�͂��܂��B
%     int(x1*log(1+x1),0,1) �́A1/4���o�͂��܂��B
%     int(4*x*t,x,2,sin(t)) �́A2*sin(t)^2*t-8*t ���o�͂��܂��B
%     int([exp(t),exp(alpha*t)]) �́A[exp(t), 1/alpha*exp(alpha*t)] ���o
%     �͂��܂��B
%     int(A,t) �́A[sin(x*t)/x, -cos(x*t)/x]
%                  [cos(x*t)/x,  sin(x*t)/x] ���o�͂��܂��B



%   Copyright 1993-2002 The MathWorks, Inc.
