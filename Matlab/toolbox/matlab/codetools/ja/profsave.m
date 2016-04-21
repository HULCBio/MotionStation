%PROFSAVE  HTML プロフィールレポートのスタティックバージョンの保存
% PROFSAVE(PROFINFO) は、プロファイラデータ構造体の FunctionTable の
% 各ファイルに対応する HTML ファイルを保存します。
% PROFSAVE(PROFINFO, DIRNAME) は、指定したディレクトリPROFSAVE のファイル
% を保存し、PROFILE('INFO') のコールからの結果を使用します。
%
% 例題:
% profile on
% plot(magic(5))
% profile off
% profsave(profile('info'),'profile_results')

%   Copyright 1984-2003 The MathWorks, Inc.
