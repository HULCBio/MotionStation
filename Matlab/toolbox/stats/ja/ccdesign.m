% CCDESIGN   中心複合計画を作成
%
% D=CCDESIGN(NFACTORS) は、要因NFACTORSに対する中心複合計画を作成します。
% 出力行列D は、N×NFACTORSであり、ここで、N は、計画の点数です。各行は、
% 計画の1つの実行を表し、実行するすべての要因の設定を含んでいます。
% 要因の値は、cube pointが、-1と1の間の値に入るように正規化されます。
%   
% D=CCDESIGN(NFACTORS,'PNAME1',pvalue1,'PNAME2',pvalue2,...) を使って、
% 追加のパラメータとその値を指定することができます。
% 使用可能なパラメータは、つぎのようになります。:
%   
%      パラメータ   値
%      'center'     含ませる中心点の数で、'uniform'は、一様な精度を与える
%                   ために必要な中心点の数を選択するもので、また、
%                   'orthogonal' (デフォルト) は、直交計画を与えるものです。
%      'fraction'   1/2のべき乗として、表されたcube portionに対する 
%                   完全要因の分割、 即ち、0 = whole design, 
%                   1 = 1/2 分割、2 = 1/4 分割など。
%      'type'       'inscribed', 'circumscribed', あるいは、'faced'の
%                   いずれかとなります。
%      'blocksize'  1ブロック内で許される最大点数
%   
% [D,BLK]=CCDESIGN(...) は、ブロック化された計画を行います。 出力ベクトル
% BLK は、ブロック数を示すベクトルです。ブロックは、同様の条件下で
% (たとえば、同じ日に)測定される実行でグループ分けしたものです。
% ブロック化された計画は、パラメータ評価についてのブロック間の違いの
% 効果を最小にします。
%
% 参考 : BBDESIGN, ROWEXCH, CORDEXCH.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2003/02/12 17:10:47 $
