% THSELECT 　雑音除去のためのスレッシュホールド値の設定
% THR = THSELECT(X,TPTR) は、文字引数 TPTR により定義された選択方式を使って、X 
% に適用するスレッシュホールド値を設定します。
% 
% 利用可能な選択方式は、TPTR = 'rigrsure'、Stein's Unbiased Risk Estimate の原理
% を使用して適切なスレッシュホールド値を選択
%   TPTR = 'heursure'、上の方法の変形
%   TPTR = 'sqtwolog'、sqrt(2*log(length(X))) をスレッシュホールド値として使用
%   TPTR = 'minimaxi'、ミニマックススレッシュホールド
%
% スレッシュホールド選択ルールは、モデル y = f(t) + e に基づいて設定されています。
% ここで、e は白色雑音 N(0,1) です。スケーリングされていないか、または白色雑音で
% ないものを取り扱うには、出力スレッシュホールド THR を再スケーリングして使うこ
% とができます(WDEN の SCAL パラメータを参照)。
%
% 参考： WDEN.



%   Copyright 1995-2002 The MathWorks, Inc.
