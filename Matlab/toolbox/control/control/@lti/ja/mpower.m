% MPOWER   LTI���f���̃x�L��v�Z
%
% MPOWER(SYS,K) �́ASYS^K �̎��s���ɃR�[������A�����ŁASYS �͓��͂Əo��
% �̐���������LTI���f���ŁAK �͐����łȂ���΂����܂���B���ʂ́A����
% LTI���f���ɂȂ�܂��B
%  * K>0 �̏ꍇ�ASYS * ... * SYS (K��) 
%  * K<0 �̏ꍇ�AINV(SYS) * ... * INV(SYS) (K��)
%  * K = 0 �̏ꍇ�A�ÓI�Q�C�� EYE(SIZE(SYS))
%
% ���� SYS^K �́A�菑���ŏ������̂悤�ɁA�`�B�֐���ݒ�ł��ĕ֗��ł��B
% ���Ƃ��΁A���̂悤�ɐݒ肷�邱�Ƃ��ł��܂��B
% 
%          - (s+2) (s+3)
%   H(s) = ------------
%          s^2 + 2s + 2
% 
% �́A���̂悤�ɓ��͂��܂��B
% 
%   s = tf('s')
%   H = -(s+2)*(s+3)/(s^2+2*s+2) 
%
% �Q�l : TF, PLUS, MTIMES, LTIMODELS.


%   Copyright 1986-2002 The MathWorks, Inc. 
