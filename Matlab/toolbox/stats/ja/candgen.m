% CANDGEN   D-最適化計画のための候補集合の作成
%
% XCAND = CANDGEN(NFACTORS,MODEL) は、要因 NFACTORS と モデル MODEL を
% 用いて、 D-最適計画に適切な候補集合を生成します。
% 出力行列 XCAND は、各行をN個の候補点の1つの座標を表す、N×NFACTORSの
% 行列です。MODEL は、つぎの文字列のいずれかとなります。
%
%     'linear'          定数と線形項 (デフォルト)
%     'interaction'     定数、線形、クロス積の項
%     'quadratic'       相互作用項と2乗項の和
%     'purequadratic'   定数、線形、および、2乗の項
%
% MODEL は、関数 X2FX で使用できる要素構成からなる行列の型でも設定できます。 
%
% [XCAND,FXCAND] = CANDGEN(NFACTORS,MODEL) は、要因値 XCAND の行列と項の値
% FXCAND の行列の両方を出力します。後者は、D-最適化計画を生成するための
% CANDEXCH への入力となることができます。
%
% ROWEXCH は、関数CANDGENを使用して、候補集合を自動的に生成し、関数
% CANDEXCHを使用して、D-最適化計画を作成します。デフォルトの候補集合を
% 修正したい場合、これらの関数を別々に、呼び出すことが望まれる場合も
% あるかもしれません。
%
% 参考 : ROWEXCH, CANDEXCH, X2FX.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2003/02/12 17:10:37 $
