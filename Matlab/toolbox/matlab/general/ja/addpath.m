% ADDPATH   サーチパスにディレクトリを追加
% 
% ADDPATH DIRNAMEは、指定したディレクトリをカレントのmatlabpathの前に追
% 加します。ディレクトリ名にスペースが含まれる場合は、DIRNAMEをコーテー
% ションで囲んでください。DIRNAME がパスセパレータで区切られた複数
% ディレクトリの場合、指定したディレクトリのそれぞれが追加されます。
% 
% ADDPATH DIR1 DIR2 DIR3 ... は、指定したすべてのディレクトリを、パスに
% 追加します。
%
% ADDPATH ... -ENDは、指定したディレクトリをパスの最後に追加します。
% ADDPATH ... -BEGINは、指定したディレクトリをパスの最初に追加します。
% ADDPATH ... -FROZEN は、付加したディレクトリに対して、ディレクトリ変更
%              の検知ができません。そのため、Windows の変更記録を保存し
%              てください(Windows のみ)。
%
% ディレクトリの指定が文字列である場合は、関数形式のシンタックス、ADDP-
% ATH('dir1','dir2',...)を使ってください。
%
% P = ADDPATH(...) は、指定したパスを追加する前のパスを出力します。
%
% 例題
%      addpath c:\matlab\work
%      addpath /home/user/matlab
%      addpath /home/user/matlab:/home/user/matlab/test:
%      addpath /home/user/matlab /home/user/matlab/test
%
% 参考 RMPATH, PATHTOOL, PATH, SAVEPATH, GENPATH, REHASH.


% Copyright 1984-2003 The MathWorks, Inc. 
