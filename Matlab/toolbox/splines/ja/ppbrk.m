% PPBRK   pp-型の構成要素
%
% [BREAKS,COEFS,L,K,D] = PPBRK(PP) は、PP に示されたpp-型を構成要素に
% 分割し、出力引数によって指定されたものと同じ数の要素を出力します。
%
% PPBRK(PP) は、何も出力しませんが、すべての構成要素を表示します。
%
% OUT1 = PPBRK(PP,PART) は、以下の文字列の1つ(の始まりのキャラクタ)で
% ある文字列 PART によって指定された個々の構成要素を出力します。:
% 'breaks', 'coefs', 'pieces' または 'l', 'order' または 'k',
% 'dim'ension, 'interval'
% しばらくの間は、
%    'guide'
% も選択肢に入っており、特に PPVALU に対して、'A Practical Guide to Splines' 
% で使用されたpp-型で必要とされる形式の係数の配列を出力します。これは、
% ベクトル値、および/または、テンソル積スプラインに対しては利用可能では
% ありません。
%
% PJ = PPBRK(PP,J) は、PP にある関数のJ番目の多項式区分のpp-型を出力
% します。
%
% PC = PPBRK(PP,[A B]) は、PP の関数を区間 [A .. B] に制限/延長して出力
% します。[] を与えると、PP がそのまま出力されます。
%
% PP がm変数スプラインを含み、PART が文字列でない場合、それは長さ m の
% セル配列でなければなりません。
%
% [OUT1,...,OUTo] = PPBRK(PP, PART1,...,PARTi) は、o<=i であるとき、
% j=1:o として、文字列 PARTj によって指定される要素を OUTj に出力します。
%
% 例題: PP が最初の変数に少なくとも4つの区分をもつ2変数スプラインを
% 含む場合、
%
%    ppp = ppbrk(pp,{4,[-1 1]});
%
% は、長方形 [pp.breaks{1}(4) .. [pp.breaks{1}(5)] x [-1 1] 上に与えられる
% ものと一致する2変数スプラインを与えます。
%
% 参考 : SPBRK, FNBRK.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
