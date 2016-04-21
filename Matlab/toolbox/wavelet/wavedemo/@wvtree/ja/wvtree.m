%WVTREE   WVTREE クラスの構築
%   T = WVTREE(X,DEPTH,WNAME) は、ウェーブレットツリー T を出力します。
%   X がベクトルの場合、ツリーは2次になります。
%   Xが行列の場合、ツリーは4次になります。
%   DWT の拡張モードは現在は1つです。
%
%   T = WVTREE(X,DEPTH,WNAME,DWTMODE) は、DWT の拡張モードととして、
%   DWTMODE を使って構築される、ウェーブレットツリー T を出力します。
%
%   T = WVTREE(X,DEPTH,WNAME,DWTMODE,USERDATA) を使って、ユーザデータ
%   フィールドを設定します。
%
%   ORDER = 2 の場合、T はベクトル(信号) X を、特定のウェーブレット 
%   WNAME でレベル DEPTH でウェーブレット分解した結果に対応する WVTREE
%   オブジェクトです。
%
%   ORDER = 4 の場合、T は、行列(イメージ) X を、特定のウェーブレット 
%   WNAME でレベル DEPTH でウェーブレット分解した結果に対応する WVTREE
%   オブジェクトです。

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Oct-1998.



%   Copyright 1995-2002 The MathWorks, Inc.
