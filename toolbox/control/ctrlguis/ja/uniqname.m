% UNIQNAME   ある集合内の個々の名前に対する最も短いユニークな値を決定
%
% UNIQNAME(Names) は、Names に与えられた Simulink ブロック名のセル配列を
% 調べ、個々のブロックをユニークに表す最も短い名前を決定します。これらの
% 名前は、LINSUB の中で得られる線形化モデルの中の状態名、入力名、出力名
% として使われます。


%   Greg Wolodkin, 7-23-98
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:17 $
