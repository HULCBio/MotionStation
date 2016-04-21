% DPCMENCO 差分パルス符号変調方式を使用して信号を符号化
%
% INDX = DPCMENCO(SIG, CODEBOOK, PARTITOIN, PREDICTOR)は、差分パルス符号
% 変調(DPCM)で符号化したインデックス INDX を生成します。符号化される信号
% はSIGです。このとき、PREDICTOR に予測伝達関数を与えます。そして、
% PARTITION、および、CODEBOOKにそれぞれ予測エラー量子化パーティションと
% コードブックを設定します。通常、M 次の伝達関数分子の形式は
% [0, n1, n2, ... nM] です。
% 
% [INDX, QUANT] = DPCMENCO(SIG, CODEBOOK, PARTITION, PREDICTOR) は、
% QUANTに量子化された値を出力します。
% 
% 入力パラメータ CODEBOOK, PARTITION、および、PREDICTORの推定には、
% DPCMOPT を使用します。
%
% 参考： QUANTIZ, DPCMOPT, DPCMDECO.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $
