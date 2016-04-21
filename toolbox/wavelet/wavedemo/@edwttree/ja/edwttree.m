%EDWTTREE   EDWTTREE クラスのコンストラクタ
%   T = EDWTTREE(X,DEPTH,WNAME) は、ε-dwt ツリー T を出力します。
%   X がベクトルの場合、ツリーは2次になります。
%   Xが行列の場合、ツリーは4次になります。
%   DWT の拡張モードは現在は1つです。
%
%   T = EDWTTREE(X,DEPTH,WNAME,DWTMODE) は、DWT の拡張モードととして、
%   DWTMODE を使って構築される、ε-dwt ツリー T を出力します。
%
%   T = EDWTTREE(X,DEPTH,WNAME,DWTMODE,USERDATA) を使って、ユーザデータ
%   フィールドを設定します。

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Sep-1999.


%   Copyright 1995-2002 The MathWorks, Inc.
