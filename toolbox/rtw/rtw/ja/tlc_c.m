% TLC_C   ブロック線図からCコードを生成するプライベートRTW関数
%
% TLC_Cは、Target Language Compilerによって、Cコードに変換されるmodel.
% rtwファイルをrtwgenを用いて生成します。
%    
% この関数は、make_rtwによって呼び出されるように設計されています。 
% 全ての引数(modelName, rtwroot, systemTargetFile, RTWVerbose, tlcArgs, 
% projectDir)は、前もって設定されていると仮定します。
%    
% 出力引数:
%      rtwFile         は、生成されるmodel.rtwファイル名です。
%      modules         は、model.cファイルを含んでい、作成される付加的な
%                      C モジュールの文字列のリストです。
%      noninlinedSFcns は、コンパイルおよびリンクされるS-functionのセル
%                      です。
%      codeFormat      は、<model> reg.h ファイルからコードの書式を決定
%                      します。
%
% 参考：make_rtw

%       Copyright 1994-2001 The MathWorks, Inc.
