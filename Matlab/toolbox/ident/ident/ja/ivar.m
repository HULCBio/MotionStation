% IVAR は、スカラ時系列の AR 部を補助変数法を使って計算します。
% 
%   MODEL = IVAR(Y,NA)
%
%   MODEL : 時系列モデル
% 
%   A(q) y(t) =  v(t)
% 
% の関連した構造情報と共に AR 部のIV 法を使った推定結果を出力(MODEL の正
% 確な構造は、HELP IDPOLY を参照)。
%
%   Y     : 時系列を単出力 IDDATA オブジェクトとして設定。詳細は、HELP 
%           IDDATA を参照。
%
%   NA    : AR 部の次数(A(q)-多項式)
%
% 上のモデルの中で、v(t) は、任意のプロセスで、次数 NC の移動平均過程(時
% 変も可)と仮定されています。NC のデフォルト値は、NA です。NC の他の値は、
%    MODEL = IVAR(Y,NA,NC)
% 
% を使って得られます。
%
%   TH = IVAR(Y,NA,NC,maxsize)
% 
% を使うことで、maxsize より多い要素をもつ行列は、このアルゴリズムでは作
% 成しません。
%
% 参考： AR.



%   Copyright 1986-2001 The MathWorks, Inc.
