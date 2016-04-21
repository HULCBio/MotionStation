% ISTRELLIS   入力が有効なトレリス構造体であるか否かをチェック
%
% [ISOK, STATUS] = ISTRELLIS(S) は、入力 S が有効なトレリス構造体をして
% いるか否かをチェックします。入力が有効なトレリス構造体の場合、ISOK は
% 1を、STATUS には空文字列を出力します。一方、ISOK が0の場合、STATUS には、
% S がなぜ有効でないトレリスなのかを示す文字列が表示されます。
%
% トレリス構造体は、つぎのフィールドをもっています。
%
%      numInputSymbols,  (入力シンボルの数)
%      numOutputSymbols, (出力シンボルの数)
%      numStates,        (状態数)
%      nextStates,       (つぎの状態行列)
%      outputs,          (出力行列)
%    
% 入力が k ビットで、出力が n ビットで表せる場合、numInputSymbols = 2^k 
% で、numOutputSymbols = 2^n となります。フィールド numStates は、状態数
% をストアします。フィールド 'nextStates' と'outputs' は、'numStates' 行
% 'numInputSymbols' 列をもつ行列です。
%
% 'nextStates' 行列の中の各要素は、0と(numStates-1)の間の整数です。
% 'nextStates' 行列の (s,u) 要素、すなわち、s 番目の行で u 番目の列の
% 要素は、スタートした状態が(s-1)で、入力ビットが10進数表現(u-1)のとき、
% つぎの状態を定義するものです。10進数への変換を行うには、最初の入力ビット
% を最上位ビット（MSB）として使います。たとえば、'nextStates' 行列の2番目
% の列は、最新の入力が 1 で、他の入力が 0 の場合、つぎの状態をストアします。
%  
% 'output' 行列の(s,u)要素は、スタートの状態が(s-1)で、入力ビットが10進数
% (u-1)の場合の出力を定義します。10進数への変換を行うには、最初の出力ビット
% を MSB として使ってください。
% 
% 参考： POLY2TRELLIS.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2003/06/23 04:34:57 $

