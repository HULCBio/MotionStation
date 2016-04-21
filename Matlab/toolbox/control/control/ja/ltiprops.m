% LTIPROPS   LTI モデルプロパティのヘルプ
%
%
% LTIPROPS は、LTI モデルの一般的なプロパティに関する詳細を出力します。
%
% LTIPROPS(MODELTYPE) は、LTI モデルの様々なタイプで設定されたプロパティに
% 関する詳細を出力します。文字列 MODELTYPE は、つぎの中のモデルタイプから
% 選んでください。
%   'tf'  :   伝達関数(TF オブジェクト)
%   'zpk' :   極-零点-ゲインモデル (ZPK オブジェクト)
%   'ss'  :   状態方程式モデル(SS オブジェクト)
%   'frd' :   周波数応答データ (FRD オブジェクト)
%
% つぎのように入力することで、
%   ltiprops tf 
% 下記の簡略形となることに注意してください。 
%   ltiprops('tf')
%
% 参考 : LTIMODELS, SET, GET.


% Copyright 1986-2002 The MathWorks, Inc.
