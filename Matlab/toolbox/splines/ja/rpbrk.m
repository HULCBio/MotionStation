% RPBRK   rp型の構成要素
%
% OUT1 = RPBRK(RP,PART) は、以下の文字列の1つ(の始まりのキャラクタ)で
% ある文字列 PART によって指定された個々の構成要素を出力します。:
%      'breaks', 'coefficients', 'pieces' または 'l', 'order' または 'k', 
%      'dimension', 'interval'.
%
% RPBRK(PP) は、何も出力しませんが、すべての構成要素を表示します。
%
% PJ = RPBRK(RP,J) は、RP にある関数のJ番目の多項式区分のrp-型を出力
% します。
%
% PC = RPBRK(RP,[A B]) は、RP にある関数を区間 [A .. B] に制限して出力
% します。
%
% RP がm変数スプラインを含み、PART が文字列でない場合、PART は長さ m の
% セル配列でなければなりません。
%
% [OUT1,...,OUTo] = RPBRK(SP, PART1,...,PARTi) は、o<=i であるとき、
% j=1:o として、文字列 PARTj によって指定された構成要素を OUTj に出力
% します。
%
% 例えば、RP が最初の変数に少なくとも4つの区分をもつ2変数スプラインを
% 含む場合、
%
%      rpp = rpbrk(rp,{4,[-1 1]});
%
% は、長方形 [rp.breaks{1}(4) .. [rp.breaks{1}(5)] x [-1 1] 上に与え
% られるものと一致する2変数スプラインを与えます。
%
% 参考 : RPMAK, RSBRK, PPBRK, SPBRK, FNBRK.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
