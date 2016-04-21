% UNDOCHECKOUT   前にチェックアウトしたものを元に戻します。
%
% UNDOCHECKOUT(FILENAME) は、ファイル FILENAME に関するチェックアウト
% を戻します。FileName は、ファイルのフルパスでなければなりません。
% FileName は、ファイルの配列でも構いません。
%
% 例題:
%
% 	undocheckout('\filepath\file.ext')
% バージョンコントロールツールから \filepath\file.ext のチェックアウトを
% 外します。
%
%	undocheckout({'\filepath\file1.ext','\filepath\file2.ext'}
% バージョンコントロールツールから \filepath\file1.ext と \filepath\file2.ext 
% のチェックアウトを外します。
%	
% 参考：CHECKIN, CHECKOUT, CMOPTS.


%   Copyright 1998-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2004/04/28 02:09:26 $
