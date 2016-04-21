% MERGE  2つの basefitoptions オブジェクトの結合
% F = MERGE(OLDF,NEWF) は、新しい fitoptions オブジェクト NEWF を、既
% に存在する fitoptions オブジェクト OLDF と組み合わせます。OLDF と 
% NEWF が、同じ 'Method' をもっている場合、NEWF の中の空でない値をもつ
% 任意のパラメータは、OLDF の中の対応する古いパラメータで書き換えられ
% ます。OLDF と NEWF が、異なる 'Method'値をもつ場合、F は、OLDF と同
% じ MEthod をもち、NEWF のフィールド 'Normalize', 'Exclude', 'Weights'
% のみが、OLDF フィールドを書き換えます。

% $Revision: 1.2.4.1 $
%   Copyright 2001-2004 The MathWorks, Inc.
