% FNBRK   型の名前または構成要素
%
% FNBRK(FN,PART) は、FN にある関数について指定された PART を出力します。
% PART のほとんどの選択については、これは FN にある関数についての情報の
% いくつかの要素です。PART のいくつかの選択については、FN にある関数に
% 関連したいくつかの関数の型です。
% PART が文字列の場合、関連する文字列の最初の文字(文字列)のみ、指定する
% 必要があります。
%
% FN の型に関わらず、PART にはつぎのものを指定します。
%
%      'dimension'     関数のターゲットの次元
%      'variables'     関数の領域の次元
%      'coefficients'  特別な型の係数
%      'interval'      関数の基本区間
%      'form'          FN にある関数を記述するために使用される型
%      [A B]           (A, B はスカラ)。同じ型ですが、区間 [A .. B] 上で
%                      FN にある1変数関数の記述を得ます。基本区間は 
%                      [A .. B] に変換されます。m変数関数に対しては、
%                      この指定が [A B] という形式でm個の要素をもつセル
%                      配列の形になっていなければなりません。
%      [] は、FN が変更されずに出力されます(FN がm変数関数のときに使用)。
%
% FN の型に依存して、以下の要素も指定できます。
%
% FNが、B-型 (あるいは、BB-型, rB-型)の場合、PART は、
%
%      'knots'         節点列
%      'coefficients'  B-スプライン係数
%      'number'        係数の数
%      'order'         スプラインの多項式次数
%
% FN が pp-型 (あるいは、rp-型)の場合、PART は、
%
%      'breaks'        ブレークポイントの列
%      'coefficients'  局所的な多項式の係数
%      'pieces'        多項式区分の数
%      'order'         スプラインの多項式の次数
%      整数 j          j番目の多項式区分のpp-型
%
% FN が st-型 の場合、PART は、
%
%      'centers'       中心
%      'coefficients'  係数
%      'number'        係数の数
%      'type'          st-型のタイプ
%
% FN が、m>1として、m変数のテンソル積のスプラインを含むならば、PART は、
% 文字列でない場合、長さ m のセル配列でなければなりません。
%
% [OUT1, ..., OUTo] = FNBRK(FN, PART1, ..., PARTi) は、j=1:o での文字列 
% PARTj によって要求される要素を OUTj に出力します。ここで o<=i です。
%
% FNBRK(FN) は、何も出力しませんが、利用可能である場合、すべての要素と
% 共に、'form' を表示します。
% 
% 例題:
%
%      coefs = fnbrk( fn, 'coef' );
%
% は、fn のスプラインの係数 (そのB-型 あるいは、そのpp-型からの係数)を
% 出力します。 
%
%      p1 = fn2fm(spline(0:4,[0 1 0 -1 1]),'B-');
%      p2 = fnrfn(spmak(augknt([0 4],4),[-1 0 1 2]),2);
%      p1plusp2 = spmak( fnbrk(p1,'k'), fnbrk(p1,'c')+fnbrk(p2,'c') );
%
% は、2つの関数 p1 と p2 の(点に関する) 和を与えます。これは、両方とも
% 同じ節点列で同じターゲットの次元をもつ同じ次数のスプラインであるため、
% 機能します。
%
%      x = 1:10; y = -2:2; [xx, yy] = ndgrid(x,y);
%      pp = csapi({x,y},sqrt((xx -4.5).^2+yy.^2));
%      ppp = fnbrk(pp,{4,[-1 1]});
%
% は、長方形 [b4,b5] x [-1,1] の pp-型 スプラインと一致するスプラインを
% 与えます。ここで、b4, b5 は、1番目の変数に対するブレークポイント列の
% 4番目と5番目の点です。 
%
% 参考 : SPMAK, PPMAK, RSMAK, RPMAK, STMAK, SPBRK, PPBRK, RSBRK, RPBRK, 
%        STBRK.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
