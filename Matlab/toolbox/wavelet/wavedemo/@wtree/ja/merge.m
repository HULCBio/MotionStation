%MERGE   各ノードのデータをマージします(組み替えます)
%   X = MERGE(T,N,TNDATA) は、ノード N の子供のノードで結合されたデータ
%   を使って、データツリー T のノード N で結合されるデータ X を組み替え
%   ます。
%
%   TNDATA は、TNDATA{k}が N の k 番目の子供のノードとなるよう結合された%   データを含むような、(ORDER x 1)行(1 x ORDER)列となるセル配列です。
%
%   1次元(あるいは2次元)データに対する IDWT(または IDWT2)を用います。
%
%   この手法は、DTREE メソッドに多重定義されています。
 
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Oct-1998.


%   Copyright 1995-2002 The MathWorks, Inc.
