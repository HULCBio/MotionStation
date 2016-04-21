% STATGET   STATS オプションパラメータ値の取得
%
% VAL = STATGET(OPTIONS,'NAME') は、統計量のオプション構造体 OPTIONS 
% から指定されたパラメータの値を抽出します。パラメータ値が OPTIONS 内に
% 規定されていない場合、空行列を出力します。パラメータ名を省略して、
% ユニークに区別できる文字列として指定することも可能です。
%   
% VAL = STATGET(OPTIONS,'NAME',DEFAULT) は、指定されたパラメータを抽出
% しますが、指定されたパラメータが OPTIONS に規定されていない([] が指定
% されている)場合、DEFAULT を出力します。
%   
% 参考 : STATSET.


%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2003/02/11 23:08:20 $
