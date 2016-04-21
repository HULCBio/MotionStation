% SPTERMS   Spline Toolboxの用語の説明
%
% EXPL = SPTERMS(TERM) は、文字列 TERM によって指定される用語の説明を含む
% 文字列、あるいは、文字列のセル配列を出力します。
% つぎの文字列の指定が可能です。
%    'B-form',  'basic interval'
%    'B-spline','breaks'
%    cubic spline interpolation', 'endconditions'
%    'not-a-knot', 'clamped', 'second', 'periodic', 'variational', 'Lagrange'
%    'cubic smoothing spline', 'quintic smoothing spline'
%    'error'
%    'knots',  'end knots', 'interior knots'
%    'least squares'
%    'NURBS', 'rational spline', 'rBform', 'rpform'
%    'roughness measure'
%    'thin-plate spline', 'centers', 'stform', 'basis function'
%    'spline'
%    'spline interpolation', 'Schoenberg-Whitney conditions'
%    'order'
%    'ppform'
%    'sites_etc'
%    'weight in roughness measure'
%
% 用語の始めの部分の文字(少なくとも2つ、しかし通常は2つで十分)だけ与える
% 必要があります。オプションの2番目の出力引数は理解された完全な用語を
% 提示します。
%
% SPTERMS(TERM) は、出力引数がない場合、何も出力しませんが、説明を 
% メッセージボックスに表します。


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
