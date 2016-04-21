% SOURCESAFE   SOURCESAFE を使って、ファイルまたはファイル群を
%              チェックインまたはチェックアウト
% 
% SOURCESAFE(FILENAMES, ARGUMENTS) は、以下で指定されたオプション
% (名前/値の組み合わせ) ARGUMENTS を使って要求されたアクションを実行します。
% FILENAMES は、ファイルの絶対パスか、ファイルのセル配列でなければなり
% ません。
%
% つぎのオプションを使用することができます。
% 
%    action    - 実行できるバージョンコントロール機能。使用可能な値は、
%                つぎのものです。
%       checkin
%       checkout
%       undocheckout
% 
%    force  -   設定した機能を実行します。使用可能な値は、つぎのものです。
%       on
%       off
% 
%    revision  - 設定したバージョンで、指定した機能を実行します。
%
%    outputfile -  ファイルをoutputfileに書き出します。
%
% 参考： CHECKIN, CHECKOUT, UNDOCHECKOUT, CMOPTS, CUSTOMVERCTRL,
%        CLEARCASE, PVCS, RCS.


%   Copyright 1998-2002 The MathWorks, Inc.
