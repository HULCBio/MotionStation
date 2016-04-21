% CHECKIN バージョンコントロールシステムの中のファイルまたはファイル
% 群をチェック
% 
%   CHECKIN(FILENAME, 'COMMENTS', COMMENT_TEXT) 
% 
% 文字列 COMMENT_TEXT 内のコマンドを使って、ソースコントロールシステム
% の中の FILENAME をチェックします。FILENAME は、ファイルの絶対パスで
% ある必要があります。FILENAME は、ファイルのセル配列でも構いません。
% チェックする前に、ファイルをセーブします。
% 
%   CHECKIN(FILENAME, 'COMMENTS', COMMENT_TEXT, OPTION1, VALUE1, ...
%      OPTION2, VALUE2)
%
% OPTIONS は、つぎのものです。
%      lock - ファイルのチェックアウトに関する状態。デフォルトはオンで、
%             設定できる値は、つぎのものです。
%          on(オン)
%          off(オフ)
%
% 例題：
%      checkin('\filepath\file.ext','comments','A sample comment')
%      Checks \filepath\file.ext into the version control tool.
%
%      checkin({'\filepath\file1.ext','\filepath\file2.ext'},'comments',...
%         'A sample comment')
%      Checks \filepath\file1.ext and \filepath\file2.ext into the
%      version control system, using the same comments for both files.
%
% 参考：CHECKOUT, UNDOCHECKOUT, CMOPTS.


%   Copyright 1998-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $ $Date: 2004/04/28 02:09:19 $
