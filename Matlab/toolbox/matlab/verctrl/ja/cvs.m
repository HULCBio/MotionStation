% CVS   RCS を使ったバージョンコントロールアクション
%
% CVS(FILENAMES, ARGUMENTS) は、つぎに指定した ARGUMENTS オプション
% (名前/値の組み合わせ) を使って、必要なアクションを実行します。
% FILENAMES は、ファイルの絶対パス、または、ファイルのセル配列のどちらか
% でなければなりません。
%
% オプション:
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
% 参考:  CHECKIN, CHECKOUT, UNDOCHECKOUT, CMOPTS, CUSTOMVERCTRL,
%        SOURCESAFE, CLEARCASE, CVS, and PVCS.


%   Copyright 1998-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2003/04/18 16:48:39 $
