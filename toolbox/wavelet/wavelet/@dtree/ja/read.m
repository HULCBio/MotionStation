%READ  DTREE オブジェクトフィールドの読み込み
%   VARARGOUT = READ(T,VARARGIN) は、DTREE オブジェクトのフィールドから
%   1つ、または複数のプロパティ値をを読み込むための最も一般的なシンタッ
%   クスです。
%
%   READ 関数を呼び出す他の方法は、以下のとおりです。
%     PropValue = READ(T,'PropName') または
%     PropValue = READ(T,'PropName','PropParam')
%     あるいは、前のシンタックスを組み合わせます。
%     [PropValue1,PropValue2, ...] = ...
%         READ(T,'PropName1','PropParam1','PropName2','PropParam2',...)
%         PropParam はオプションです。
%
%   PropName では以下の項目が選択できます。
%     'sizes': PropParam = ノードのインデックスベクトル
%
%     'data' :
%        PropParam なしか、あるいは、
%        PropParam = 1つの末端ノードインデックス とするか、
%        PropParam = 末端ノードインデックスの列ベクトル
%        最終的に、PropValue は、セル配列になります。
%
%   例題:
%     x = [0:0.1:1];
%     t = dtree(2,3,x);
%     t = nodejoin(t,[4;5]);
%     sAll = read(t,'sizes');
%     sNod = read(t,'sizes',[0,4,5]);
%     dAll = read(t,'data');
%     dNod = read(t,'data',[4;5]);
%     stnAll = read(t,'tnsizes');
%     stnNod = read(t,'tnsizes',[4,5]);

% INTERNAL OPTIONS:
%------------------
% 'tnsizes':
%    Without PropParam or with PropParam = Vector of terminal node ranks.
%    The terminal nodes are ordered from left to right.
%
% 'an':
%    With PropParam = Vector of nodes indices.
%    NODES = READ(T,'an') returns all nodes of T.
%    NODES = READ(T,'an',NODES) returns the valid nodes of T
%    contained in the vector NODES.
%
%   参考: DISP, GET, SET, WRITE

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jan-97.



%   Copyright 1995-2002 The MathWorks, Inc.
