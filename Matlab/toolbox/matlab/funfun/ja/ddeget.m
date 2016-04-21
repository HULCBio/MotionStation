% DDEGET  DDE OPTIONSパラメータの取得
% VAL = DDEGET(OPTIONS,'NAME') は、積分オプション構造体OPTIONSから
% 指定したプロパティの値を取得し、プロパティ値がOPTIONSに指定されていな
% い場合は空行列を出力します。NAMEの設定は、プロパティ名全体を設定する
% のではなく、ユニークに判断できる文字で構いません。プロパティ名の設定は、
% 大文字、小文字の区別はありません。[] は使用できる正しい型のOPTIONS
% 引数です。
%   
% VAL = DDEGET(OPTIONS,'NAME',DEFAULT) は、上記のように指定したプロ
% パティを取得しますが、指定したプロパティがOPTIONSにない場合は、
% VAL = DEFAULT を出力します。たとえば、
%   
%       val = ddeget(opts,'RelTol',1e-4);
%   
% RelTol プロパティがoptsで指定されていない場合は、val = 1e-4を出力します。
%   
% 参考 ： DDESET, DDE23.


%   Copyright 1984-2003 The MathWorks, Inc. 
