% MEYER 　Meyerウェーブレット
% [PHI,PSI,T] = MEYER(LB,UB,N) は、区間 [LB,UB] で N 点の等間隔グリッド
% 上で計算された Meyer ウェーブレットとスケーリング関数を出力します。N 
% は2のべき乗でなけれはなりません。
%
% 出力引数はグリッド T 上で計算されたスケーリング関数 PHI とウェーブレッ% ト関数 PSI です。これらの関数は、[-8 8]で効率的なサポートです。
%
% 4番目の引数の設定は、つぎの関数が必要とされる場合にのみ与えることがで
% きます。
% 
%   [PHI,T] = MEYER(LB,UB,N,'phi')
%   [PSI,T] = MEYER(LB,UB,N,'psi')
% 
% 4番目の引数が用いられ、その引数が、'phi' または  'psi' のいずれかと等しくない
% 場合には、出力は、メインオプションと同じものになります。
%
% 参考： MEYERAUX, WAVEFUN, WAVEINFO.



%   Copyright 1995-2002 The MathWorks, Inc.
