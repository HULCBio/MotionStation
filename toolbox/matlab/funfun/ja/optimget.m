% OPTIMGET    OPTIM OPTIONSパラメータの取得
%
% VAL = OPTIMGET(OPTIONS,'NAME') は、最適化オプション構造体OPTIONS
% から指定したパラメータの値を抽出し、パラメータ値がOPTIONSで指定されて
% いない場合は空行列を出力します。パラメータを一意的に識別する頭文字をタ
% イプするだけで設定することができます。パラメータ名の大文字と小文字の区
% 別は無視されます。[] は有効なOPTIONSの引数です。
%   
% VAL = OPTIMGET(OPTIONS,'NAME',DEFAULT) は、指定されたパラメータを
% 上記のように抽出しますが、指定されたパラメータがOPTIONSで指定されて
% いない場合([]の場合)は、DEFAULT を出力します。たとえば、
%   
%     val = optimget(opts,'TolX',1e-4);
%   
% は、TolX プロパティが opts 内で指定されていない場合は、val = 1e-4 を
% 出力します。
%   
% 参考 ： OPTIMSET.



%   Copyright 1984-2003 The MathWorks, Inc. 
