% GALLERY   Highamテスト行列
% 
% [out1,out2,...] = GALLERY(matname、param1、param2、...)は、引数とし
% て行列のファミリ名であるmatnameと、ファミリの入力パラメータをもちま
% す。使用できる行列ファミリは、下記を参照してください。ほとんどの関数
% は、行列の次数を指定する入力引数をもつか、そうでなければ、単一の出力
% をします。さらに情報を得るためには、matnameが行列のファミリ名のとき、
% "help private/matname"とタイプしてください。
%
% cauchy    Cauchy行列
% chebspec  Chebyshevスペクトル微分行列
% chebvand  Chebyshev多項式用のVandermonde-like行列
% chow      Chow行列     - 特異Toeplitz lower Hessenberg行列
% circul    Circulant行列
% clement   Clement行列  - 主対角がゼロの三重対角行列
% compar    Comparison行列 
% condex    行列の条件数の推定に対するCounter-例題
% cycol     循環する列をもつ行列
% dorr      Dorr行列     - 対角に支配的な要素をもつ条件数の悪い三重対角
%           行列(出力引数が3)
% dramadah  逆行列が大きい整数要素をもつような1と0の要素をもつ行列
% fiedler   Fiedler行列  - 対称行列
% forsythe  Forsythe行列 - 置換されたJordanブロック
% frank     Frank行列    - 条件数の悪い固有値をもつ行列
% gearmat   Gear行列
% grcar     Grcar行列    - 敏感な固有値をもつToeplitz行列
% hanowa    複素平面の垂直線に固有値をもつ行列
% house     Householder行列 (出力引数が3)
% invhess   上Hessenberg行列の逆行列
% invol     Involutory行列
% ipjfact   因子要素をもつHankel行列(出力引数が2)
% jordbloc  Jordanブロック行列
% kahan     Kahan行列    - 上台形行列
% kms       Kac-Murdock  - Szego Toeplitz行列
% krylov    Krylov行列
% lauchli   Lauchli行列  - 長方形行列
% lehmer    Lehmer行列   - 対称正定行列
% leslie    Leslie 行列
% lesp      実数の敏感な固有値をもつ三重対角行列
% lotkin    Lotkin行列
% minij     対称正定行列MIN(i,j).
% moler     Moler行列    - 対称正定行列
% neumann   離散Neumann問題の特異行列(スパース)
% orthog    直交行列、または、ほぼ直交行列
% parter    Parter行列   - PIに近い特異値をもつToeplitz行列
% pei       Pei行列
% poisson   Poisson方程式のブロック三重対角行列(スパース)
% prolate   Prolate行列  - 対称で条件数が悪いToeplitz行列
% randcolu  正規化した列と設定した特異値をもつランダム行列
% randcorr  設定した固有値をもつランダムな相関行列
% randhess  ランダムな直交上Hessenberg行列
% randjorth ランダムなJ-直交行列
% rando     要素が-1、0、1のランダム行列
% randsvd   あらかじめ割り当てられた特異値と指定されたバンド幅をもつ
%           ランダム行列
% redheff   Redhefferの0と1からなる行列
% riemann   Riemann仮説に関連する行列
% ris       Ris行列      - 対称Hankel行列	
% smoke     Smoke行列    - "smoke ring"疑似スペクトルをもつ複素行列
% toeppd    対称正定Toeplitz行列
% toeppen   五重対角Toeplitz行列(スパース)
% tridiag   三重対角行列(スパース)
% triw      Wilkinsonらにより議論された上三角行列
% wathen    Wathen行列   - 有限要素行列(スパース、ランダム要素)
% wilk      Wilkinsonによる種々の行列(出力引数が2)
%
% GALLERY(3)は、条件数の悪い3行3列行列です。
% GALLERY(5)は、興味深い固有値問題です。固有値と固有ベクトルを求めて
% みてください。
% 
% 参考：MAGIC, HILB, INVHILB, HADAMARD, PASCAL, WILKINSON, ROSSER, 
%       VANDER.

%   References:
%   [1] N. J. Higham, Accuracy and Stability of Numerical Algorithms,
%       Second edition, Society for Industrial and Applied Mathematics,
%       Philadelphia, 2002; Chapter 28.
%   [2] J. R. Westlake, A Handbook of Numerical Matrix Inversion and
%       Solution of Linear Equations, John Wiley, New York, 1968.
%   [3] J. H. Wilkinson, The Algebraic Eigenvalue Problem,
%       Oxford University Press, 1965.
%
%   Nicholas J. Higham
%   Copyright 1984-2002 The MathWorks, Inc.
