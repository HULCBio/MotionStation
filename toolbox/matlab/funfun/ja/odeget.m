% ODEGET  ODEのOPTIONSパラメータを抽出
%
% VAL = ODEGET(OPTIONS,'NAME') は、積分器オプションの構造体OPTIONS
% から指定されたプロパティの値を抽出し、プロパティ値がOPTIONSで指定され
% ていなければ空行列を出力します。プロパティを一意的に識別する頭文字を
% タイプするだけで十分です。プロパティ名に対しては、大文字と小文字の区別
% は無視されます。[] は、有効なOPTIONSの引数です。
%   
% VAL = ODEGET(OPTIONS,'NAME',DEFAULT) は、上記のように設定したプロ
% パティを抽出しますが、プロパティがOPTIONSで指定されなければ、
% VAL = DEFAULT を出力します。たとえば
%   
%       val = odeget(opts,'RelTol',1e-4);
%   
% は、RelTolプロパティがoptsで指定されなければ、val = 1e-4を出力します。
%    
% 参考：ODESET, ODE45, ODE23, ODE113, ODE15S, ODE23S, ODE23T, ODE23TB


%   Mark W. Reichelt and Lawrence F. Shampine, 3/1/94
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:52:30 $
