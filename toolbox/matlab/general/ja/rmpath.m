%RMPATH サーチパスからディレクトリを削除
% RMPATH DIRNAME  は、カレントのmatlabpathから指定したディレクトリを削除
% します。名前が空白を含む場合、DIRNAME を quotes で囲んでください。
% DIRNAME 　がパスセパレータで区切られた複数ディレクトリのセットである場合、
% 指定されたディレクトリのそれぞれが削除されます。
%
% RMPATH DIR1 DIR2 DIR3  は、指定したすべてのディレクトリをパスから削除
% します。
%
% ディレクトリの指定が文字列に保存されている場合は、関数形式のシンタック
% ス RMPATH('dir1','dir2',...) を使ってください。
%
% P = RMPATH(...) は、指定したパスを削除する以前のパスを出力します。
%
% 例題
%     rmpath c:\matlab\work
%     rmpath /home/user/matlab
%     rmpath /home/user/matlab:/home/user/matlab/test:
%     rmpath /home/user/matlab /home/user/matlab/test
%
% 参考 ADDPATH, PATHTOOL, PATH, SAVEPATH, GENPATH, REHASH.

%   Copyright 1984-2003 The MathWorks, Inc.
