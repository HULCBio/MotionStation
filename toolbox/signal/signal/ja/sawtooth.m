% SAWTOOTH   ノコギリ波または三角波を発生 
%
% SAWTOOTH(T) は、時間ベクトルTの要素に対して周期2πをもつノコギリ波を生
% 成します。SAWTOOTH(T) は、SIN(T) と似ていますが、正弦波ではなく、-1と1
% にピークをもつノコギリ波を作成します。
%
% SAWTOOTH(T,WIDTH) は、変形三角波を生成します。ここで、WIDTH は、0と1の
% 間のスカラのパラメータであり、最大となる位置を0と2πの間で決定します。
% この関数は、0から WIDTH*2*pi の区間では-1から1に増加し、WIDTH*2*pi か
% ら 2*pi の区間では、1から-1に線形的に減少します。従って、0.5のパラメー
% タは、ピーク値が1で、ピーク間隔が対称な標準三角形を示します。 SAWTOOTH
% (T,1) は、SAWTOOTH(T) と等価です。
%
% 注意: 
% この関数は入力を大きな数にすると不正確になります。
%
% 参考：   SQUARE, SIN, COS, CHIRP, DIRIC, GAUSPULS, PULSTRAN, 
%          RECTPULS, SINC, TRIPULS.



%   Copyright 1988-2002 The MathWorks, Inc.
