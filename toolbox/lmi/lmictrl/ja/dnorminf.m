% [gain,peakf]=dnorminf(sys,tol)
%
% つぎの離散時間伝達関数のピークゲインを計算します。
%                                   -1
%             G (z) = D + C (zE - A)  B
%
% (A,E)が単位円上に固有値をもたない場合にのみ、ノルムは有限です。
%
% 入力:
%   SYS        G(z)のsystem行列の記述(LTISYSを参照)。
%   TOL        目標相対精度(デフォルト = 0.01)。
%
% 出力:
%   GAIN       ピークゲイン(Gが安定なときは、RMSゲイン)。
%   PEAKF      このノルムが得られる周波数。すなわち、
%
%                               j*PEAKF
%                       || G ( e        ) ||  =  GAIN
%
%
% 参考：    NORMINF.



% Copyright 1995-2002 The MathWorks, Inc. 
