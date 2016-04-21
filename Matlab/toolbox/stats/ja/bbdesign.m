% BBDESIGN   Box-Behnken 計画を作成
%
% D=BBDESIGN(NFACTORS) は、要因NFACTORSに対するBox-Behnken 計画を生成
% します。出力行列Dは、N×NFACTORSです。ここで、N は、計画の点数です。
% 各行には、-1 と 1の間になるようにスケールされたすべての要因に対する
% 設定をリストしています。 
%
% D=BBDESIGN(NFACTORS,'PNAME1',pvalue1,'PNAME2',pvalue2,...)により、
% 追加のパラメータとその値を指定することができます。使用可能なパラメータ
% は、つぎのとおりです。
% 
%       パラメータ   値
%       'center'     含むことのできるcenter点の数
%       'blocksize'  ブロック内で使用できる点の最大数
%
% [D,BLK]=BBDESIGN(...) は、blocked計画を求めます。出力ベクトル BLK は、
% ブロック数のベクトルです。
%
% Box と Behnken は、要因の数が3-7, 9-12, あるいは、16に等しい場合の計画を
% 提唱しました。この関数は、これらの計画を作成します。他の値のNFACTORSに
% 対して、Box と Behnken により表にされていない場合でさえも、この関数は、
% 同様の方法を使って、構成される計画を作成します。しかし、これらは大き
% すぎるため実用的でない可能性もあります。
%
% 参考 : CCDESIGN, ROWEXCH, CORDEXCH.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2003/02/12 17:08:58 $
