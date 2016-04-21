% SPRAND   スパース一様分布乱数行列
% 
% R = SPRAND(S) は、S と同じスパース構造をもち、一様分布乱数を要素とする
% 行列を出力します。
%
% R = SPRAND(m,n,density) は、ランダムな m 行 n 列のスパース行列で、ほぼ
% density*m*n 個の一様分布する非ゼロ要素をもちます。SPRAND は、大きくて、
% 密度が小さい行列を作成します。m*n が小さかったり密度が大きければ、要求し
% たものよりも非ゼロが少ない行列を作成します。
%
% R = SPRAND(m,n,density,rc) は、条件数の逆数がほぼ rc と等しくなります。
% R は、ランク1の行列の和から構成されます。
%
% rc が長さ lr < =  min(m,n) のベクトルの場合、R は最初の lr の特異値が 
% rc で、他はすべてゼロになります。この場合、R は与えられた特異値をもつ
% 対角行列に、ランダムな平面回転を適用して作られます。R は、多くの位相的
% 構造や、代数的構造をもっています。
%
% 参考：SPRANDN, SPRANDSYM.


%   Rob Schreiber, RIACS, and Cleve Moler, MathWorks, 9/10/90.
%   Revised 1/28/91, 2/12/91, RS; 8/12/91, CBM.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:03:33 $
