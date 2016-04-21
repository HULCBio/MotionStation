% GETSIGPREF は、Signal Processing Toolboxに対するユーザの優先順位を取得
% します。val = GETSIGPREF(prop) は、Signal Processing Toolbox の優先順
% 位の中で、プロパティ prop に関連する値を出力します。prop が存在しない
% 場合、GETSIGPREF は、空行列を出力します。prop がセル配列である場合、出
% 力 val は、同じ大きさのセル配列になります。
%
% val = GETSIGPREF(prop,default) は、対象となるプロパティに関連したカレ
% ント値が存在しない場合、prop に対してデフォルト値を出力します。
%
% GETSIGPREF は、Signal Processing Toolbox の優先されるものに関するプロ
% パティ名/値の組をすべて含む構造体です。この構造体が空の場合、セーブさ
% れている優先順位はありません。
%
% 参考：   SETSIGPREF.

%   Copyright 1988-2001 The MathWorks, Inc.
