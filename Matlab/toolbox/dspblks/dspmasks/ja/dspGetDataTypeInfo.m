% dtInfo = dspGetDataTypeInfo(blk,maxVal)
%
%   blk    : 固定小数点の有効なブロック名。デフォルト値は'gcb'の出力です。
%   maxVal : 'best precision' の場合の分数のビット数を計算するために使用
%            される値。デフォルトは、-1です。
%   
% この関数は、ブロックの dtat タイプについての情報を含んだ構造体を出力
% します。構造体は、以下のフィールドをもちます。:
% DataTypeDeterminesFracBits : データタイプが仮数ビットの数で定義するのに
%                              十分である場合1です。このフィールドは、
%                              組み込みに対してと、FIX に等しくないデータ
%                              オブジェクトのクラスに対して1です。
% DataTypeIsCustomFloat      : 単精度と倍精度として扱われる float(32,8)、
%                              float(64,11) を除くクラス FLOAT で示される
%                              ものの1つ
% DataTypeIsSigned           : 符号付きか符号なしかのどちらか
% DataTypeWordLength         : ビットのトータルな数; -1に等しいブーリアン
% DataTypeFracOrMantBits     : 分数ビットの数(固定小数点)または、仮数ビット
%                              (浮動小数点)
% DataTypeObject             : sint, uint, sfrac, ufrac, sfix, ufix, fload
%                              コマンドによって出力されたクラスオブジェクト。
%                              他の場合はすべて [] に等しい
%   
% 注意: この関数は、以下のパラメータ変数がブロックのマスクに存在すると
%       仮定します。:
%   
% dataType     : 'Fixed-point' と 'User-defined' と同じようにサポートされる
%                組み込みのデータタイプを表示するポップアップ
% wordLen      : dataType に 'Fixed-point' が選択されたとき、有効となる
%                エディットボックス
% udDataType   : dataType に 'User-defined' が選択されたとき、有効となる
%                エディットボックス
% fracBitsMode : 2つの選択をもつポップアップ: 'Best precision' と
%                'User-defined'
% numFracBits  : fracBitsMode が 'User-defined' のとき有効になるエディット
%                ボックス
%   
% 注意: この関数は、マスクパラメータが VISIBLE のときのみコールされます。
%       (すなわち、'Show additional parameters' ボックスがチェックされて
%       いるときです)。そうでない場合、最後に選択された設定は必要ではなく、
%       最後に適用された設定の値を出力します。
%
% 注意: これは、DSP Blocksetのマスクユーティリティです。一般的な目的の
%       関数として使用されることを意図していません。


%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/07/22 21:04:24 $
