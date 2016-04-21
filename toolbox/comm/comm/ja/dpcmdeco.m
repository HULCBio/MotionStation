% DPCMDECO 差分パルス符号変調を使って復号
%
% SIG = DPCMDECO(INDX, CODEBOOK, PREDICTOR)は、差分パルス符号変調(DPCM)
% で符号化したインデックス信号INDXを復号します。このとき、PREDICTOR に
% 予測伝達関数を与えます。CODEBOOK には予測エラー量子化コードブックを
% 設定します。通常、M 次の伝達関数の形式は [0, n1, n2, ... nM] です。
% 正しい復号結果を得るには、これらのパラメータが符号化パラメータと一致
% する必要があります。
% 
% [SIG, QUANT] = DPCMDECO(INDX, CODEBOOK, PREDICTOR) は、QUANT に量子化
% した予測エラーを出力します。
% 
% 入力パラメータ CODEBOOK と PREDICTOR の推定には、関数 DPCMOPT を使用
% します。
% 
% 参考： QUANTIZ, DPCMOPT, DPCMENCO.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $
