% BOOTSTRP   ブートストラップ統計量
%
% BOOTSTRP(NBOOT,BOOTFUN,...) は、NBOOT 回のブートストラップデータ標本を
% 表示し、関数 BOOTFUN を使って、それらを解析します。引数 NBOOT は、正の
% 整数でなければなりません。3番目とそれ以降の引数は、データです。
% BOOTSTRP は、データのブートストラップサンプルを BOOTFUN に渡します。
% 
% [BOOTSTAT,BOOTSAM] = BOOTSTRP(...) において、引数 BOOTSTAT は、一つの
% ブーストラップサンプルに BOOTFUN の結果を含んだものになっています。
% BOOTFUN が行列を出力する場合、この出力は、BOOTSTAT の中のストレージに
% 保管するために一つの長いベクトルに変換されます。引数 BOOTSAM は、
% データ行列の行の指標となる行列です。
% 
% 例題：
% ランダムサンプルの100回のブーストラップの平均のサンプルをベクトル Y 
% から作成します。
% 
%       M = BOOTSTRP(100, 'mean', Y)
% 
% ベクトル Y の行列 X への回帰用に、200回のブーストラップを行った係数
% ベクトルのサンプルを作成します。
% 
%      B = BOOTSTRP(200, 'regress', Y, X)
% 


%   B.A. Jones 9-27-95, ZP You 8-13-98
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:10:28 $
