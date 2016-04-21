% MENULABEL   キーボードと等価なメニューラベルとアクセラレータキーの解釈
% 
% 注意: 
% この関数は廃止されており、MATLAB 5ではuimenuの文字列labelが、すべての
% プラットフォームで同様に機能します。
%
% [LABEL、ACC] = MENULABEL(INLABEL) は、文字列 INLABEL を解釈して、適切な
% ラベル設定文字列を指定し、uimenuの呼び出しで使用します。文字列 INLABEL
% では、文字をキーボードと等価にするために、その文字の前に & を使用します。
% メニューラベル内で '&' を使いたい場合は、INLABEL 内で '\&' を入力して
% ください。'^q' をアクセラレータキーにするためには、文字列の最後に 'q' 
% を使ってください。


%   Steven L. Eddins, 27 May 1994
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:08:33 $
