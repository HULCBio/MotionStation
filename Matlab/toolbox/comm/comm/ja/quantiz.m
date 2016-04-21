% QUANTIZ   量子化インデックスと量子化した出力値を作成
%
% INDX = QUANTIZ(SIG, PARTITION) は、決定ポイント PARTITION に基づいて、
% 入力信号 SIG の量子化インデックス INDEX を作成します。INDX の各要素は、
% 範囲[0 : N-1]にある N 個の整数の1つです。PARTITION は、境界を指定する
% 厳密に昇順の N-1ベクトルです。INDX = 0, 1, 2, ..., N-1の要素は、範囲
% (-Inf, PARTITION(1)], (PARTITION(1), PARTITION(2)], (PARTITION(2), 
% PARTITION(3)], ..., (PARTITION(N-1), Inf) の SIG を表します。
% 
% [INDX, QUANT] = QUANTIZ(SIG, PARTITION, CODEBOOK) は、QUANT の量子化の
% 出力値を作成します。CODEBOOK は、出力集合を含む長さ N のベクトルです。
% 
% [INDX, QUANT, DISTOR] = QUANTIZ(SIG, PARTITION, CODEBOOK) は、量子化の
% 推定歪み値 DISTOR を出力します。
% 
% このツールボックスには、復号量子化関数がありません。つぎのように簡単に
% 復号計算を行うことができるからです。
% 
%       Y = CODEBOOK(INDX+1)
%
% 参考： LLOYDS, DPCMENCO, DPCMDECO.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $
