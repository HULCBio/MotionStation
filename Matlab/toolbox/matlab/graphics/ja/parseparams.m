% PARSEPARAMS   最初の文字引数を検索
% 
% [REG、PROP] = PARSEPARAMS(ARGS) は、セル配列 ARGS を読み込み、つぎの
% 2つの引数に分解します。
% 
%    REG は、ARGS 内の最初の文字引数にヒットする前のすべての引数を含む
%    PROP は、最初にヒットする文字引数を含んで、それ以降のすべての引数を含む
% 
% PARSEPARAMS は、入力引数として VARARGIN を使って、関数内で可能な限り
% 属性と値を分離します。


%   Chris Portal 2-17-98
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:56:04 $
