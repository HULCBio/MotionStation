% dTypeID = dspCalcSLBuiltinDataTypeID(blk,dtInfo)
%
%   blk    : 固定小数点が有効であるブロック名
%   dtInfo : blk に対する dspGetDataTypeInfo からの構造体
%  
% もし適用される場合、ブロックに対してSimulinkの組み込みのデータタイプ
% IDを計算します。; ブロックがバックプロパゲーションモードの場合-1を、
% データタイプが組み込みでない場合-2を出力します。
%  
% 注意: この関数は、以下のパラメータがブロック内に存在するものと仮定します。:
%   
%   dataType : 'Fixed-point' と 'User-defined' と同じようにサポート
%               される組み込みのデータタイプをリストするポップアップ
%   
% 注意: この関数は、dataType マスクパラメータが VISIBLE のときのみコール
%       されます。(すなわち、'Show additional parameters' ボックスが
%       チェックされているときです)。そうでない場合、最後に選択された
%       値を必要とせず、最後に適用された設定の値を出力します。
%
% 注意: これは、DSP Blocksetのマスクユーティリティ関数です。一般的な
%       目的の関数として使用されることを意図していません。


%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/07/22 21:04:23 $
