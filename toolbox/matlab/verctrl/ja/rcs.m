% RCS    RCS を使ったバージョンコントロールアクション
%
% RCS(FILENAMES, ARGUMENTS) は、つぎに指定した ARGUMENTS オプション
% (名前/値)を使って、必要なアクションを実行します。
% FILENAMES は、ファイルの絶対パス、または、ファイルのセル配列のどちらか
% でなければなりません。
%
% オプション：
%      action - 実行されるバージョンコントロールアクション
%         checkin
%         checkout
%         undocheckout
%   
%      lock - ファイルのロック
%         on
%         off
%
%      revision - アクションを実行するレビジョンの指定
%
%      outputfile - ファイルを outputfile に書き込む
%
% 参考：CHECKIN, CHECKOUT, UNDOCHECKOUT, CMOPTS, CUSTOMVERCTRL,
%    SOURCESAFE, CLEARCASE, PVCS.


%   Copyright 1998-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2004/04/28 02:09:24 $
