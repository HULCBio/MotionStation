% SUBSREF は、IDFRD モデル用のsubsref メソッドです。
%    
%      H(Outputs,Inputs) は、I/O チャンネルのサブセットを選択します。
%      H.Fieldname は、GET(MOD,'Filedname') と等価です。
% これらの表現は、H(1,[2 3]).inputname 、または、squeeze(H.cov(25,2,3,:,:))
% のような、サブスクリプト参照として正しい記法を利用できます。
% 
% チャンネル参照は、チャンネル名や番号で設定されます。
% 
%     H('velocity',{'power','temperature'})
% 
% 単出力システムに対して、H(ku) は入力チャンネル ku を選択し、単入力シス
% テムに対して、H(ky) は、出力 ky を選択します。
%
% H('measured') は、測定された入力チャンネルを選択し、ノイズ入力を無視し
% ます。そして、ResponseData と CovarianceData のみをキープします。
%
% H('noise') は、SpectrumData と NoiseCovariance を抽出します。



%   Copyright 1986-2001 The MathWorks, Inc.
