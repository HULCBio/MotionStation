% MODSTRUC �́AMS2TH �̒��Ŏg���郂�f���\�����쐬���܂��B
% 
%   MS = MODSTRUC(A,B,C,D,K,X0)
%
%   MS = ���ʂƂ��ďo�͂��郂�f���\��
%   A,B,C,D,K,X0 �́A��ԋ�ԃ��f���̍s��ł��B
%
%   xnew = A x(t) + B u(t) + K e(t)
%   y(t) = C x(t) + D u(t) + e(t)
%
% �����ŁAxnew �́Ax(t+T)�A�܂��́Adx(t)/dt �ł��BX0 �́A������Ԃł��B
%
% �����̍s��̗v�f�̒��ŌŒ肷����̂͐��l�Őݒ肵�A���肷����̂� NaN
% �Őݒ肵�܂��B
% 
% ���F A=[0 1;NaN NaN].
%        X0 �̃f�t�H���g�l�́A�[���ł��B
%  
% �Q�l�F CANFORM, MS2TH.

%   Copyright 1986-2001 The MathWorks, Inc.
