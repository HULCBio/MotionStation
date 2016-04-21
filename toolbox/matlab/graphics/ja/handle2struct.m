% HANDLE2STRUCT   Handle Graphicsの階層を構造体配列に変換
% 
% hgS = HANDLE2STRUCT(H) は、H 内のハンドルのベクトルをつぎのフィールド
% をもつ構造体配列 hgS に変換します。
% 
%    type       : オブジェクトタイプ
%    properties : プロパティ値を含む構造体
%    children   : 各々の子オブジェクトに対する要素をもつ構造体配列
%    handle     : 変換時のオブジェクトのハンドル
%
% 参考：STRUCT2HANDLE.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:55:50 $
%   D. Foti  11/19/97
%   Built-in function.

