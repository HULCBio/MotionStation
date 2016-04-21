% LTIMODELS   LTIモデルのヘルプ
%
%
% LTIMODELS は、Control System Toolbox でサポートしている LTI モデルの様々な
% タイプに関する一般的な情報を与えます。
%
% LTIMODELS(MODELTYPE) は、各タイプの LTI モデルについて、追加で詳細事項や
% 例題を出力します。
% 文字列 MODELTYPE は、つぎの中のモデルタイプから選んでください。
%   'tf'  :   伝達関数(TF オブジェクト)
%   'zpk' :   極-零点-ゲインモデル (ZPK オブジェクト)
%   'ss'  :   状態方程式モデル(SS オブジェクト)
%   'frd' :    周波数応答データモデル(FRD オブジェクト)
%
% つぎのように入力することで、
%   ltimodels zpk
% 下記の簡略形となることに注意してください。
%   ltimodels('zpk')
%
% 参考 : LTIPROPS, TF, ZPK, SS, FRD.


% Copyright 1986-2002 The MathWorks, Inc.
