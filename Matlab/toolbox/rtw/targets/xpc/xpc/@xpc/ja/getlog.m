% GETLOG は、シミュレーションにより出力される種々のログの一部を取得します。
% 
% GETLOG(XPCOBJ, LOGNAME, START, NUMPOINTS, INTERLEAVE) は、xPC オブジェク
% ト XPCOBJ のプロパティである、TimeLog, StateLog, OutputLog, TETLog のロ
% グの一つをアップロードします。GET コマンドで得られる結果と異なり、ログの
% 一部がアップロードでき、リンクに時間を必要とするような場 合には、時間の
% 節約になります。LOGNAME は、(XPCOBJのフィールドと同じ) 'TimeLog','Stat-
% eLog', 'OutputLog', 'TETLog'の内の一つです。フルネームではなく名前の一部
% を使うこともできます。START, NUMPOINTS, INTERLEA VE は、スタートポイント
% ポイント数、データの間引きを設定します。これらを何も設定しない場合、すべ
% てのログが出力されます。XPCOBJ と LOGN AME は、必ず必要なものです。
% 
% GETLOG(XPCOBJ, LOGNAME, START) は、サンプル数 START のみを出力します 。
% 
% GETLOG(XPCOBJ, LOGNAME, START, NUMPOINTS) は、interleave(間引き設定) 1 
% では、START で開始するサンプル数 NUMPOINTS を出力します。
% 
% 最初のポイントは、(0でなく)1で番号付けられています。
% 
% GETLOG は、スカラ XPCOBJ 用にのみ使われます。
% 
% 参考： GET.

%   Copyright 1994-2002 The MathWorks, Inc.
