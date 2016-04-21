% CELLFUN は、セル配列関数です。
% 
% D = CELLFUN(FUN、C)、ここで、FUNは、つぎのいずれかを設定します。 
%
% 	'isreal'    -- 実数セル要素に対して、真
% 	'isempty'   -- 空セル要素に対して、真
% 	'islogical' -- 論理セル要素に対して、真
% 	'length'    -- セル要素の長さ
% 	'ndims'     -- セル要素の次元数
% 	'prodofsize'-- セル要素の中の要素数
%
% Cは、セル配列で、セル配列の各要素に設定した関数FUNを適用し、その結果を
% 出力します。Dは、Cの対応するセル要素上にFUNを適用した結果を含むCと同じ
% 大きさのdoubleの配列です。
%
% D = CELLFUN('size'、C、K) は、Cの各要素のK番目の次元に関する大きさを出
% 力します。
% 
% D = CELLFUN('isclass'、C、CLASSNAME)は、要素のクラスが、文字列CLASSN-
% AMEに一致する場合、真を出力します。ISA関数と異なり、CLASSNAMEのサブク
% ラスの'isclass'は、偽を出力します。
% 
% 注意：Cがオブジェクトを含む場合、CELLFUNは、FUNの任意のオーバロード
% バージョンを呼びません。


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $

