% function out = formloop(P,K,sgnfb,sgnff)
%
% mutoolsのマニュアルにあるゲイン/位相余裕の例題の相互結合構造を作成しま
% す。
%
% デフォルトは、y2 (sgnfb = 'neg')における負のフィードバックとu1 (sgnff 
% = 'pos')における正のフィードフォワードです。
%
% 入力:				          出力:
% P     - プラント			  out - MIMO閉ループシステム
% K     - コントローラ
% sgnfb - フィードバック符号('neg'または'pos')
% sgnff - フィードフォワード符号('neg'または'pos')
%

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:30:29 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
