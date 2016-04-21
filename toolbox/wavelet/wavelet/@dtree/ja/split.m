%SPLIT   終点のノードデータを分離します(分解します)
%   TNDATA = SPLIT(T,N,X) は、データツリー T の末端ノード N に関連する
%   データ X を分解します。
%   TNDATA は、TDATA{k} が N の k 番目の関連データを含むような 
%   (ORDER x 1) のセル配列です。
%
%   注意: 
%   このメソッドは、以下のオブジェクトのクラスに多重定義されています。
%   ----------
%   クラス DTREE の SPLIT メソッドは、最も左側に位置する子供の N のデー
%   タを割り当てます。
%   ----------

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Oct-96.


%   Copyright 1995-2002 The MathWorks, Inc.
