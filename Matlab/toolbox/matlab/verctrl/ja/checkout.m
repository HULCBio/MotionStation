% CHECKOUT   バージョンコントロールシステムのファイル、または、ファイル群
%            のチェック
%
% CHECKOUT(FILENAME) は、バージョンコントロールシステムから FILENAME 
% をチェックします。FILENAME は、ファイルの絶対パスである必要があります。
% FILENAME は、ファイルのセル配列でも構いません。デフォルトでは、すべて
% のファイルが、チェックアウトになっています。
%
%   CHECKOUT(FILENAME, OPTION1, VALUE1, OPTION2, VALUE2, ...)
%
% OPTIONS には、つぎのものを設定することができます。
%      lock - ファイルのチェックアウトに関する状態。デフォルトはオンで、
%             設定できる値は、つぎのものです。
%          on(オン)
%          off(オフ)
%
%      revision - チェックするファイルのバージョンを指定
%
% 例題：
%      checkout('\filepath\file.ext')
%      Checks out \filepath\file.ext from the version control system.
%
%      checkout({'\filepath\file1.ext','\filepath\file2.ext'})
%      Checks out \filepath\file1.ext and \filepath\file2.ext from the
%      version control system.
%
% 参考：CHECKIN, UNDOCHECKOUT, CMOPTS.


%   Copyright 1998-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $ $Date: 2004/04/28 02:09:20 $

