% WPVIEWCF    ウェーブレットパケットカラー係数のプロット表示
% wpviewcf(T,D,CMODE) は、ツリー構造 T の不連続ノードに関するカラー係数をプロッ
% ト表示します。
%   T は、ツリー構造です。
%   D は、データ構造です。
%   CMODE は、カラーモードを表示する整数です。
% 1: 'FRQ : Global + abs'
% 2: 'FRQ : By Level + abs'
% 3: 'FRQ : Global'
% 4: 'FRQ : By Level'
% 5: 'NAT : Global + abs'
% 6: 'NAT : By Level + abs'
% 7: 'NAT : Global'
% 8: 'NAT : By Level'
%
% wpviewcf(T,D,CMODE,NB) は、NB で指定されたカラーを用います。
%
% 例題:
%   x = sin(8*pi*[0:0.005:1]);
%   [t,d] = wpdec(x,4,'db1');
%   plottree(t);
%   wpviewcf(t,d,1);
%
% 参考： MAKETREE, WPDEC.



% $Revision: 1.1 $
% Copyright 1995-2002 The MathWorks, Inc.
