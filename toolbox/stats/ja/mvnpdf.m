% MVNPDF   多変量正規分布密度関数 (pdf)
%
% Y = MVNPDF(X) は、ゼロの平均と、n行d列の行列 X の各行を評価した単位
% 共分散行列を使って、多変量正規分布の確率密度を含むn行1列のベクトル Y 
% を出力します。X の行は観測に対応し、列は分散、または座標に対応します。
%
% Y = MVNPDF(X,MU) は、平均 MU と X の各行を評価した単位共分散行列を
% 使って、多変量正規分布の密度を出力します。MU は、1行d列のベクトル、
% または、密度がMU の対応する行を使って X の各行に対して評価された場合は、
% n行d列の行列です。MU は、スカラ値でも指定できます。その場合は、MVNPDF 
% が、X のサイズに合うようにリサイズします。
%
% Y = MVNPDF(X,MU,SIGMA) は、平均 MU と、X の各行を評価した共分散 SIGMA 
% を使って多変量正規分布の密度を出力します。SIGMA は、d行d列の行列、
% または、密度が SIGMA の対応するページを使って X の各行に対して評価
% された場合、例えば、MVNPDF が X(I,:) と SIGMA(:,:,I) を使って Y(I) が
% 計算された場合は、d-d-n配列です。ユーザが SIGMA のみを指定したい場合は、
% デフォルト値を使用するために、MU に対して空行列を渡してください。
%
% X が、1行d列のベクトルである場合、MVNPDF は、MU の leading dimension、
% または SIGMA の trailing dimension に一致するよう複製を行います。
%
% 例題:
%
%      mu = [1 -1];
%      Sigma = [.9 .4; .4 .3];
%      X = mvnrnd(mu, Sigma, 10);
%      p = mvnpdf(X, mu, Sigma);
%
% 参考 : MVNRND, NORMPDF.


%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/28 16:51:27 $
