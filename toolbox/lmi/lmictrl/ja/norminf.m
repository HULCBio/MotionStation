% [gain,peakf]=norminf(sys,tol)
%
% 周波数応答のピークゲインを計算します。
%                                   -1
%             G (s) = D + C (sE - A)  B
%
% (A,E)が虚数軸上に固有値をもたない場合にのみ、ノルムは有限です。
%
% 入力:
%   SYS        G(s)のシステム行列の記述(LTISYSを参照)。
%   TOL        目標相対精度(デフォルト = 0.01)。
%
% 出力:
%   GAIN       ピークゲイン(Gが安定ならばRMSゲイン)。
%   PEAKF      ノルムが達成される周波数。つぎのようになります。
%
%                     || G ( j * PEAKF ) ||  =  GAIN
%
% 参考：    DNORMINF, QUADPERF, MUPERF.



% Copyright 1995-2002 The MathWorks, Inc. 
