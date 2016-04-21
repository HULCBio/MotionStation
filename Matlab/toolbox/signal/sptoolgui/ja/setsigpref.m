% SETSIGPREF は、Signal Processing Toolbox に対して、ユーザの優先順位を
% 設定します。
% 
% SETSIGPREF(prop, val) は、Signal Processing Toolbox に関連した優先順位
% のリストに、プロパティ名/値(prop, val)を加えます。与えられたタグをもつ
% プロパティが既に存在している場合、その値は書き換えられます。prop と val
% は、同じ大きさのセル配列です。優先順位は、SIGPREFS と名付けたグローバ
% ル変数にセーブされます。
%
% SETSIGPREF(prop, val, diskFlag) は、diskFlag = 1 のとき、情報をディス
% クにセーブすること以外は、上の機能と同じです。sigprefs.mat が、パス上
% またはカレントディレクトリ内に存在しない場合、SETSIGPREF は、ディレク
% トリ名に対してユーザにダイアログを作成するか否かを尋ねます。sigprefs.
% mat は、ユーザが設定したディレクトリ内にセーブされます。この演算が、ユ
% ーザによりキャンセルされた場合、SETSIGPREF は1を出力します。
%
% フィールド名を正しく取得するように注意を払ってください。ある間違いによ
% り、新しいフィールドが、誤って付加される可能性があります。
%
% 参考：   GETSIGPREF.

%   Copyright 1988-2001 The MathWorks, Inc.
