% MVNRND   多変量正規分布のランダム行列
%
% R = MVNRND(MU,SIGMA) は、平均ベクトル MU と共分散行列 SIGMA を使って
% 多変量正規分布から抽出されたランダムベクトルのn行d列の行列 R を出力
% します。MU は、n行d列の行列で、MVNRND は、MU の対応する行を使って R の
% 各行を生成します。SIGMA は、d行d列の対称半正定行列か、d-d-n配列です。
% SIGMA が配列の場合、MVNRND は、SIGMA の対応するページを使って、例えば
% MVNRND が MU(I,:) と SIGMA(:,:,I) を使って R(I,:) を計算するように、R の
% 各行を生成します。MU が1行d列のベクトルの場合、MVNRND は、SIGMA の 
% trailing dimension に一致するように複製を行います。
%
% R = MVNRND(MU,SIGMA,CASES) は、共通の1行d列の平均ベクトルと、共通の
% d行d列の共分散行列 SIGMA を使って多変量正規分布から抽出されたランダム
% ベクトルの CASES行d列の行列 R を出力します。
%
% R = MVNRND(MU,SIGMA,CASES,T) は、SIGMA == T'*T となる SIGMA の 
% Cholesky因子 T を与えます。T は、エラーチェックは行われません。
%
% [R,T] = MVNRND(...) は、後でより効果的にコールして再利用することの
% できる Cholesky因子 T を出力します。
%
% SIGMA が3次元配列の場合、MVNRND は、入力 T を無視し、出力 T を作成
% しません。


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:13:15 $
