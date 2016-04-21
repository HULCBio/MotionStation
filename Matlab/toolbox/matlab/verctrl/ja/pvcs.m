% PVCS   PVCS Version Managerを使って、ファイルまたはファイル群を
%        チェックインまたはチェックアウト
% 
% PVCS(FILENAMES, ARGUMENTS) は、以下で指定されたオプション(名前/値の
% 組み合わせ) ARGUMENTS を使って要求されたアクションを実行します。
% FILENAMES は、ファイルの絶対パスか、ファイルのセル配列でなければ
% なりません。
%
% つぎのオプションを使用できます。
%
%    action   - 機能するバージョンコントロール挙動、つぎの値が使用可能です。
%       checkin
%       checkout
% 
%    lock  -  ファイルをロックします。つぎの値が使用可能です。
%       on
%       off
%  
%    view  - MATLAB コマンドウインドウにファイルを表示します。しかし、
%            チェックは行いません。つぎの値が使用可能です。
%       on
%       off
% 
%    configfile  - 適切な PVCS プロジェクトにファイルを設定します。
%
%    revision  -  設定したバージョンで、指定した機能を実行します。
%
%    outputfile -  ファイルをoutputfileに書き出します。
%
% 参考： CHECKIN, CHECKOUT, UNDOCHECKOUT, CMOPTS, CUSTOMVERCTRL,
% 　　   CLEARCASE, RCS, SOURCESAFE.


%   Copyright 1998-2002 The MathWorks, Inc.
