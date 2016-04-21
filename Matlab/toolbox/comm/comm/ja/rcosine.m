% RCOSINE コサインロールオフフィルタを設計
%
% NUM = RCOSINE(Fd, Fs) は、ディジタル転送標本化周波数 Fd によりディジ
% タル信号をフィルタリングする FIR コサインロールオフフィルタを設計します。
% このフィルタに対する標本化周波数は Fs です。Fs は、Fd よりも大きく、
% Fs/Fd は整数でなければなりません。デフォルトロールオフファクタは0.5
% です。デフォルトの遅延時間は3です。すなわち、フィルタの遅延は、3/Fd 秒
% となります。
% 
% [NUM, DEN] = RCOSINE(Fd, Fs, TYPE_FLAG) は、フィルタの設計法を指示します。
% TYPE_FLAG には、'iir'、'sqrt'、あるいは、'iir/sqrt' のような組み合わせ
% を当てることができます。このとき、引数の順序は重要ではありません。
% 'fir'      FIR ロールオフコサインフィルタの設計（デフォルト）
% 'iir'      FIR ロールオフコサインフィルタの IIR 近似を設計
% 'normal'   通常のコサインロールオフフィルタの設計（デフォルト）
% 'sqrt'     ルートコサインロールオフフィルタの設計
% 'default'  デフォルトの使用(FIR, Normalコサインロールオフフィルタ)
% 
% [NUM, DEN] = RCOSINE(Fd, Fs, TYPE_FLAG,  R) は、ロールオフファクタ R 
% を設定します。R は範囲 [0, 1] の実数です。
% 
% [NUM, DEN] = RCOSINE(Fd, Fs, TYPE_FLAG, R, DELAY) は、フィルタの遅延 
% DELAY を設定します。DELAY は正の整数でなければなりません。Delay/Fd は、
% 秒単位でのフィルタの遅延です。
% 
% [NUM, DEN] = RCOSINE(Fd, Fs, TYPE_FLAG, R, DELAY, Tol) は、IIR フィルタ
% 設計に許容値 TOL を設定します。TOL のデフォルト値は0.01です。
% 
% 希望するフィルタが FIR フィルタである場合、DEN の出力が1になります。
% 
% 参考： RCOSFLT, RCOSIIR, RCOSFIR, RCOSDEMO.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $
