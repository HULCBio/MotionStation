% UPDATE_TOOLBOX_CACHE は、パス上にパスとファイルのキャッシュを作成します。
%
% UPDATE_TOOLBOX_CACHE は、カレント MATLAB パスのツールボックスの部分や
% 各ディレクトリの内容の一覧を、パス上のツールボックスディレクトリにより
% 含まれているメソッドやプライベートディレクトリ同様に保存します。
%
% 保存した MAT ファイルは、構造体配列 CachedPath を含んでいます。
%
% CachedPath.name は、MATLABROOT に関連したディレクトリの名前を含んでい
% ます。
%
% CachedPath.contents は、ディレクトリの中のすべての名前を含むキャラクタ
% 文字列です。これらは、0 を使って分離され、0 0 を使って、終了文字を表わ
% します。
%
% CachedPath.isdir は、名前に対して1つの値をもつキャラクタフラグベクトル
% で、名前がディレクトリである場合1で、他の場合は0です。



% $Revision: 1.1 $
%   Copyright 1984-2001 The MathWorks, Inc.
