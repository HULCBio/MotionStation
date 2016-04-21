% FINFO 　パス上の標準的なファイルハンドラに対してファイルタイプを識別
%
% [TYPE, OPENCMD, LOADCMD, DESCR] = finfo(FILENAME)
%
% TYPE    - FILENAME または未知のものに対するタイプを含みます。
%
% OPENCMD - ハンドラが検出されないか、あるいはFILENAME が読み取り不可能
%           な場合は、FILENAME をオープンまたは編集するコマンドを含んで
%	    いるか、あるいは空です。
%
% LOADCMD - ハンドラが検出されないか、あるいはFILNAME が読み取り
%           不可能な場合は、FILENAME からデータをロードするコマンドを
%	    含んでいるか、あるいは空です。
%
% DESCR   - FILENAME が読み取り不可能な場合は、FILENAME の説明または
%           エラーメッセージを含みます。
%
% 参考： OPEN, LOAD



%   Copyright 1984-2002 The MathWorks, Inc.
