%POLAR  極座標プロット
% POLAR(THETA、RHO) は、半径 RHO に対する角度 THETA(ラジアン)の極座標
% プロットを行います。POLAR(THETA,RHO,S) は、文字列 S で指定したライン
% スタイルを使います。有効なラインスタイルの詳細については、PLOT を参照
% してください。
%
%   POLAR(AX,...) は、GCA ではなく AX にプロットします。 
%
%   H = POLAR(...) は、H にプロットオブジェクトのハンドルを出力します。
%
%   例題:
%      t = 0:.01:2*pi;
%      polar(t,sin(2*t).*cos(2*t),'--r')
%
%   参考 PLOT, LOGLOG, SEMILOGX, SEMILOGY.

%   Copyright 1984-2002 The MathWorks, Inc. 
