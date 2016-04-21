%WRITE   WPTREE オブジェクトフィールドの値の書き込み
%   T = write(T,'cfs',NODE,COEFS) は、末端ノード NODE に対する係数を書き%   込みます。
%
%   T = write(T,'cfs',N1,CFS1,'cfs',N2,CFS2, ...) は、末端ノード N1,N2,
%   ... に対する係数を書き込みます。
%
%   注意:
%     係数値は、任意のサイズをもちます。
%     これらのサイズを取得するために、S = READ(T,'sizes',NODE) または、
%     S = READ(T,'sizes',[N1;N2; ... ]) を使います。
%
%   例題:
%     % ウェーブレットパケットツリーの作成
%     x = rand(1,512);
%     t = wpdec(x,3,'db3');
%     t = wpjoin(t,[4;5]);
%     plot(t);
%
%     % 値の書き込み
%     sNod = read(t,'sizes',[4,5]);
%     cfs4  = zeros(sNod(1,:));
%     cfs5  = zeros(sNod(2,:));
%     t = write(t,'cfs',4,cfs4,'cfs',5,cfs5);
%
%   参考: DISP, GET, READ, SET

%   INTERNAL OPTIONS :
%----------------------
%   The valid choices for PropName are:
%     'ent', 'ento', 'sizes':
%        Without PropParam or with PropParam = Vector of nodes indices.
%
%     'cfs':  with PropParam = One node indices.
%       ,
%     'allcfs', 'entName', 'entPar', 'wavName': without PropParam.
%     
%     'wfilters':
%        without PropParam or with PropParam = 'd', 'r', 'l', 'h'.
%
%     'data' :
%        without PropParam or
%        with PropParam = One terminal node indices or
%             PropParam = Vector terminal node indices.
%        In the last case, the PropValue is a cell array.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jan-97.


%   Copyright 1995-2002 The MathWorks, Inc.
