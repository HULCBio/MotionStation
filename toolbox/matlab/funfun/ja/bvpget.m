% BVPGET  BVP OPTIONSパラメータの取得
% 
% VAL = BVPGET(OPTIONS,'NAME')は、積分オプション構造体OPTIONSからNAMEプ
% ロパティの値を抽出します。指定したプロパティが、OPTIONSの中に設定され
% ていない場合、空行列が出力されます。NAMEの設定は、プロパティ名全体を設
% 定するのではなく、ユニークに判断できる文字で構いません。プロパティ名の
% 設定は、大文字、小文字の区別はありません。[]は、使用できる正しい型の
% OPTIONS引数です。
% 
% VAL = BVPGET(OPTIONS,'NAME',DEFALUT)は、上述したように設定したNAMEのプ
% ロパティ値を抽出します。しかし、設定したプロパティがOPTIONSの中で設定
% されていなければ、VAL = DEFAULTを出力します。たとえば、
% 
%    val = bvpget(opts,'RelTol',1e-4);
% 
% は、RelTolプロパティが、optsに指定されていない場合、val = 1e-4になります。
%   
% 参考：BVPSET, BVPINIT, BVPVAL, BVP4C.


%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2003 The MathWorks, Inc. 
