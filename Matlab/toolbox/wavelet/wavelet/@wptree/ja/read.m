%READ   WPTREE オブジェクトフィールドの値を読み込む
%   VARARGOUT = READ(T,VARARGIN) は、WPTREE オブジェクトのフィールドから%   1つ、または複数のプロパティ値をを読み込むための最も一般的なシンタッ
%   クスです。
%
%   READ 関数を呼び出す他の方法は、以下のとおりです。
%     PropValue = READ(T,'PropName') または、
%     PropValue = READ(T,'PropName','PropParam')
%     あるいは、前のシンタックスを組み合わせます。
%     [PropValue1,PropValue2, ...] = ...
%         READ(T,'PropName1','PropParam1','PropName2','PropParam2',...)
%         PropParam はオプションです。
%
%   PropName では以下の項目が選択できます。
%     'ent', 'ento', 'sizes' (WPTREE を参照):
%        PropParam がない場合、PropValue は、上位ノードのインデックス次
%        数のツリーノードのエントロピー(または、最適なエントロピーかサイ%        ズ)か、ノードインデックスのベクトルである PropParam を含みま
%        す。
%
%     'cfs': PropParam = 1つの末端ノードインデックスとした場合
%        cfs = READ(T,'cfs',NODE) は、
%        cfs = READ(T,'data',NODE) と等価で、末端ノード NODE の係数を出
%        力します。
%
%     'entName', 'entPar', 'wavName' (WPTREE を参照), 'allcfs':
%        PropParam がない場合
%        cfs = READ(T,'allcfs') は、cfs = READ(T,'data') と等価です。
%        PropValue は、ツリーノードの上位のノードインデックス次数で設計
%        された情報を含みます。
%     
%     'wfilters' (WFILTERS を参照):
%        PropParam がないか、または PropParam = 'd', 'r', 'l', 'h' とな
%        ります。
%
%     'data' :
%        PropParam なしか、あるいは、
%        PropParam = 1つの末端ノードインデックス とするか、
%        PropParam = 末端ノードインデックスの列ベクトル
%        最終的に、PropValue は、セル配列になります。
%        PropParam がない場合、PropValue は、上位ノードインデックスの次 %        数のツリーノードの係数を含みます。
%
%   例題:
%     x = rand(1,512);
%     t = wpdec(x,3,'db3');
%     t = wpjoin(t,[4;5]);
%     plot(t);
%     sAll = read(t,'sizes');
%     sNod = read(t,'sizes',[0,4,5]);  
%     eAll = read(t,'ent');
%     eNod = read(t,'ent',[0,4,5]); 
%     dAll = read(t,'data');
%     dNod = read(t,'data',[4;5]);
%     [lo_D,hi_D,lo_R,hi_R] = read(t,'wfilters');
%     [lo_D,lo_R,hi_D,hi_R] = read(t,'wfilters','l','wfilters','h');
%     [ent,ento,cfs4,cfs5]  = read(t,'ent','ento','cfs',4,'cfs',5);
%
%   参考: DISP, GET, SET, WPTREE, WRITE

% INTERNAL OPTIONS:
%------------------
% 'tnsizes':
%    Without PropParam or with PropParam = Vector of terminal node ranks.
%    The terminal nodes are ordered from left to right.
%    Examples:
%      stnAll = read(t,'tnsizes');
%      stnNod = read(t,'tnsizes',[1,2]);

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jan-97.


%   Copyright 1995-2002 The MathWorks, Inc.
