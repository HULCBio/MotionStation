% RESI2   多重極の留数
% 
% RESI2(U,V,POLE,N,K) は、次数 N の多重極の留数と、[1 -pole] の K 乗の
% 分母を出力します。ここで、U と V はオリジナルの多項式の商 U/V を表わし
% ます。たとえば、P が多重度2の極の場合は、このルーチンは最初に K = 1、
% つぎに K = 2を使って、N = 2 によって2回呼び出されます。K が与えられ
% なければ、デフォルトは N になります。N が与えられなければ、デフォルトは
% 1になります。
% 
% RESI2 は、多重極の部分分数展開を計算するために、RESIDUE で使用されます。
% 
% 参考：RESIDUE, POLYDER.


%   Charles R. Denham, MathWorks, 1988.
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:01:50 $
