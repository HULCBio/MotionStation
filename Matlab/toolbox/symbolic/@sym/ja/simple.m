% SIMPLE   �V���{���b�N���A�܂��́A�s��̍ł��Z���\���̌���
% SIMPLE(S) �́AS �̂������̈قȂ�㐔�I�ȗ��������s���AS �̕\����Z��
% ����ȗ�����\�����A�ł��Z���\�����o�͂��܂��BS �́A�V���{���b�N�I�u�W
% �F�N�g�ł��BS ���s��Ȃ�΁A���ʂ͍s��S�̂��ł��Z���Ȃ�\���ł��B����
% ���A�X�̗v�f���ł��Z���Ƃ͌���܂���B
%
% [R, HOW] = SIMPLE(S) �́A�ȗ����̓r�����ʂ�\�����܂���B�������A�ł�
% �Z���\���Ƌ��ɁA���̊ȗ����̕��@�����������񂪓����܂��BR �́A�V���{
% ���b�N�I�u�W�F�N�g�ŁAHOW �͕�����ł��B
%
% ��� :
%
%      S                          R                  HOW
%
%      cos(x)^2+sin(x)^2          1                  combine(trig)
%      2*cos(x)^2-sin(x)^2        3*cos(x)^2-1       simplify
%      cos(x)^2-sin(x)^2          cos(2*x)           combine(trig)
%      cos(x)+(-sin(x)^2)^(1/2)   cos(x)+i*sin(x)    radsimp
%      cos(x)+i*sin(x)            exp(i*x)           convert(exp)
%      (x+1)*x*(x-1)              x^3-x              collect(x)
%      x^3+3*x^2+3*x+1            (x+1)^3            factor
%      cos(3*acos(x))             4*x^3-3*x          expand
%
%      syms x y positive
%      log(x) + log(y)            log(x*y)           combine
%
% �Q�l   SIMPLIFY, FACTOR, EXPAND, COLLECT.



%   Copyright 1993-2002 The MathWorks, Inc.
