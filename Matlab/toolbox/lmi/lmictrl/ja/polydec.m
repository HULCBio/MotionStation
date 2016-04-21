% [c,vertx] = polydec(pv,p)
% vertx = polydec(pv)
%
% ボックス変動のパラメータベクトルPVと、パラメータベクトルの値Pを与える
% と、POLYDECは、パラメータボックスの端点(VERTXの列)と、端点集合でのPの
% 凸分解C = (c1,...,cn)を出力します。
%
%       P = c1*VERTX(:,1) + ... + cn*VERTX(:,n)
%
%       cj >=0 ,              c1 + ... + cn = 1
%
% 端点のリストVERTXは、
%
%              VERTX = POLYDEC(PV)
% 
% とタイプインすることで得ることができます。
%
% 参考：    PVEC, PVINFO, AFF2POL, HINFGS.



%  Copyright 1995-2002 The MathWorks, Inc. 
