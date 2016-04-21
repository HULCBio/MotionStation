% RMVAR  FISから変数を除去
% 
% fis2 = RMVAR(fis,'varType',varIndex) は、FIS 行列 fis と関連したファジィ
% 推論システムから設定された変数を除去します。
%
% [fis2,errorStr] = RMVAR(fis,'varType',varIndex) は、必要なエラーメッセー
% ジを文字列 errorStr に出力します。
%
% 例題
%    a = newfis('tipper');
%    a = addvar(a,'input','service',[0 10]);
%    a = addvar(a,'input','food',[0 10]);
%    getfis(a)
%    a = rmvar(a,'input',1);
%    getfis(a)
%
% 参考    ADDMF, ADDVAR, RMMF.



%   Copyright 1994-2002 The MathWorks, Inc. 
