%DBSTATUS すべてのブレークポイントのリスト
% DBSTATUS は、ERROR, CAUGHT ERROR, WARNING, NANINF を含むデバッガが
% 知っているすべてのブレークポイントのリストを表示します。
%
%
% DBSTATUS MFILEは、指定されたM-ファイル内で設定されたブレークポイントを
% 表示します。MFILEは、m-ファイル関数名、または、MATLABPATHの相対部分パ
% ス名でなければなりません(PARTIALPATHを参照)。  
%
%   S = DBSTATUS(...) は、ブレークポイント情報を、つぎの項目からなるM行1列
% の構造体に出力します。
%     name - 関数名
%     line - ブレークポイントの行番号からなるベクトル
%     expression -- 'line' フィールドのラインに相当するブレークポイント
%                    conditional expression 文字列のセルベクトル
%     cond -- 条件の文字列 ('error', 'caught error', 'warning', または 
%             'naninf').
%     identifier -- cond が 'error', 'caught error', または 'warning' 
%     のいずれかである場合、特定の cond state が設定される、MATLAB 
%     Message Identifier 文字列のセルベクトルです。
%
% 参考 DBSTEP, DBSTOP, DBCONT, DBCLEAR, DBTYPE, DBSTACK, DBUP, DBDOWN,
%      DBQUIT, ERROR, PARTIALPATH, WARNING.

%   Steve Bangert, 6-25-91.
%   Copyright 1984-2003 The MathWorks, Inc. 
