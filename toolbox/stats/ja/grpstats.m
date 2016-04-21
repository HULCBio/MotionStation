% GRPSTATS   グループ毎の統計量
%
% GRPSTATS(X,GROUP) は、X の各列の GROUP 毎の MEANS を出力します。
% X は、観測行列です。GROUP は、ベクトル、文字配列、または文字列のセル
% 配列として定義されるグループ化変数です。GROUP は、グループ化変数の値の
% それぞれユニークな結合によって X 内の値を({G1 G2 G3} のように)グループ化
% するために 様々なグループ化変数のセル配列としても構いません。
% 
% [MEANS,SEM,COUNTS,GNAME] = GRPSTATS(X,GROUP) は、SEM の中の平均の標準
% 誤差と、COUNTS 内の各グループの要素の数、GNAME 内の各グループの名前を
% 与えます。
% 
% GRPSTATS(X,GROUP,ALPHA) は、各平均に関する 100(1-ALPHA)% の信頼区間も
% プロット表示します。


%   B.A. Jones 3-5-95
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:07:31 $
