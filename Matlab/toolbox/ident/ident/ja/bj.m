% BJ 予測誤差法による Box -Jenkins モデルの推定
%
%   M = BJ(Z,[nb nc nd nf nk])、または、
%   M = BJ(Z,'nb',nb,'nc',nc,'nd',nd,'nf',nf,'nk',nk) 
%       (省略した次数はゼロとみなされ、引数の順番は、任意です)
%
%   M : 推定した共分散と構造情報を含んで、IDPOLY オブジェクトの型で表し
%       た推定したモデルとして出力します。M の詳細なフォーマットは、help
%       IDPOLY を参照してください。
%
%   Z : IDDATA オブジェクトで表したモデル推定に使用するデータ、詳細は 
%       HELP IDDATA を参照してください。
%
% [nb nc nd nf nk] は、つぎのように表される Box-Jenkins モデルの次数と遅
% れを表します。
%
% 	    y(t) = [B(q)/F(q)] u(t-nk) +  [C(q)/D(q)]e(t)
%
% 別の表現として、M = BJ(Z,Mi) を使うことができます。ここで、Mi は、ID-
% POLY で作成されたモデル、または、推定されたモデルのいずれかです。
% 最小化は、Mi で設定されたパラメータで初期化されます。
%
% M = BJ(Z,nn,Property_1,Value_1, ...., Property_n,Value_n) を使って、モ
% デル構造とアルゴリズムに関連したすべてのプロパティを設定できます。プロ
% パティ名/値の一覧については、HELP IDPOLY、または、IDPROPS ALGORITHM を
% 参照してください。



%   Copyright 1986-2001 The MathWorks, Inc.
