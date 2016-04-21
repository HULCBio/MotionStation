% GETSEQUENCE 分解した構造化要素の一連の部分の抽出
% SEQ = GETSEQUENCE(SE) は、SEが構造化要素配列の場合、SE の分解から出力
% される構造化要素群の個々のものを含むもう一つの構造化要素配列 SEQ を戻
% します。SEQ は、SE と等価ですが、SEQ の要素は、分解の結果ではありません。% 
% 例題
% -------
% STREL を、3行3列より大きい正方の構造化要素に分解します。GETSEQUENCE を
% 使って、分解した構造化要素を抽出することができます。
%
%       se = strel('square',5)
%       seq = getsequence(se)
%
% オプション'full'の設定で IMDILATE を使って、5 行 5 列の正方行列を構造化
% 要素を作成し、膨張処理に連続的に使ってみましょう。
%
%       imdilate(1,seq,'full')
%
% 参考：IMDILATE, IMERODE, STREL.



% $Revision: 1.1 $
%   Copyright 1993-2002 The MathWorks, Inc.  
