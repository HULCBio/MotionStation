% CLEARCASE Clearcase を使ったバージョンコントロールアクション
%
% CLEARCASE(FILENAMES, ARGUMENTS) は、つぎに示すようにARGUMENT オプション
% (名前/値)を使って、必要なアクションを行います。
% FILENAMES は、ファイルの絶対パス、または、ファイルのセル配列のどちらか
% を設定します。
%
%   オプション：
%      action - 実行するバージョンコントロールアクション
%         checkin
%         checkout
%
%      lock - ファイルのロック
%         on
%         off
%
%       force - 生じるアクションへの制限
%         on
%         off
%
%      revision - アクションを実行するバージョンの指定
%
% 参考：CHECKIN, CHECKOUT, UNDOCHECKOUT, CMOPTS, CUSTOMVERCTRL,
%       RCS, PVCS, SOURCESAFE.


%   Copyright 1998-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $ $Date: 2004/04/28 02:09:21 $
