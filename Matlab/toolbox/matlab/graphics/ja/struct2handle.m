% STRUCT2HANDLE     構造体からHandle Graphics階層を作成
%
% STRUCT2HANDLE(S, PARENTS) は、構造体 S に記述されているハンドル
% グラフィックオブジェクトをPARENTS にリストされているオブジェクトの子として
% 作成します。S と PARENTS は、要素の数が等しい必要があります。
% STRUCT2HANDLE(...,'convert') は、構造体 S の中に存在する他のオブジェク
% トのハンドルを含むすべてのプロパティ値を新しい値に更新します。
% STRUCT2HANDLE(...,'all') は、オブジェクトを再ストアするとき
% 'Serializable' を無視し、すべてのオブジェクトを S に再ストアします。
% その中には、'Serializable' が 'off' に設定されているものを含みます。
% H = STRUCT2HANDLE(...) は、S のトップレベルから作成されるオブジェクト
% のハンドルを出力します。
%
% S は、つぎのフィールドを含んで、handle2struct から出力される構造体です。
%    type       : オブジェクトタイプ
%    properties : プロパティ値を含む構造体
%    children   : 各々の子に対する要素をもつ構造体配列
%    handle     : 変換時のオブジェクトのハンドル
%
% 参考：HANDLE2STRUCT.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:56:15 $
%   D. Foti  11/19/97
%   Built-in function.
