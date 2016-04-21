% DDEX1  DDE23に対する例題1
% これは、遅延微分方程式(DDE)のシステムの解の簡単な定式化、計算、
% プロットを説明する Wille' and Bakerの例題です。 
%
% 微分方程式
%
%        y'_1(t) = y_1(t-1)  
%        y'_2(t) = y_1(t-1)+y_2(t-0.2)
%        y'_3(t) = y_2(t)
%
% は、 t <= 0 に対して history y_1(t) = 1, y_2(t) = 1, y_3(t) = 1 で
% ある [0, 5] で解かれます。
%
% lagsは、ベクトル[1, 0.2]として指定され、遅延微分方程式はサブ関数DDEX1DEに
% コード化され、履歴は関数DDEX1HISTによって評価されます。履歴は定数なので、
% ベクトルとして与えられます。
%       sol = dde23(@ddex1de,[1, 0.2],ones(3,1),[0, 5]);
%
%   参考 ： DDE23, @.


%   Jacek Kierzenka, Lawrence F. Shampine and Skip Thompson
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $  $Date: 2004/04/28 01:48:19 $
