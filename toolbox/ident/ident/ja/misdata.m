%MISDATA: 欠損データの推定
%
%   DATAE = MISDATA(DATAN,MODEL)
%   DATAE = MISDATA(DATAN,MAXITER,TOL)
%
%   DATAN: IDDATAフォーマットのデータ。入力または、出力の欠損データは、
%          NaNで指定します。
%   MODEL: 任意の IDMODEL (IDPOLY, IDSS, IDARX, IDGREY) フォーマットの
%          モデル。このモデルは、欠損データの復元のために利用されます。
%   MAXITER: N4SID モデルのデフォルト次数が指定されていない場合に利用
%            されます。MAXITER までイタレーションが実行され、MODEL と
%            DATAE が交互に推定されます。イタレーションは、欠損データ
%            の推定値の変化が TOL % 以下になると終了します。
%            (デフォルトでは、MAXITER = 10 で TOL = 1 です。)
%   DATAE: 欠損データの推定値を含む IDDATA フォーマットのデータセット。
%          つまり、DATAN の欠損データが推定値で置き換えられます。

%	L. Ljung 00-05-10


%	Copyright 1986-2001 The MathWorks, Inc.
