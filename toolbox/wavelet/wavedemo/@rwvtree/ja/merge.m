%MERGE   各ノードのデータをマージします(組み替えます)
%   X = MERGE(T,N,TNDATA) rは、ノード N の子供のノードで結合されたデータ
%   を使って、データツリー T のノード N を結合したデータ X を組み替えま
%   す。
%
%   TNDATA は、TNDATA{k}が N の k 番目の子供のノードとなるよう結合された%   データを含むような、(ORDER x 1)行(1 x ORDER)列となるセル配列です。
%
%   手法は、1次元 (または2次元) データに対する IDWT (または IDWT2) を使
%   います。
%
%   この手法は、DTREE メソッドで多重定義されています。
 
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Sep-1999.


%   Copyright 1995-2002 The MathWorks, Inc.
