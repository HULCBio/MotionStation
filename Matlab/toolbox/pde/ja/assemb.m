% ASSEMB   境界条件から行列 Q と行列 H とベクトル G とベクトル R を組み
% 立てます。[Q,G,H,R] = ASSEMB(B,P,E) は、行列 Q と行列 H とベクトル G 
% とベクトル R を組み立てます。Q は、システム行列に加えられ、混合境界条
% 件からの寄与を含みます。G は、右辺に加えられ、一般的ノイマン境界条件と
% 混合境界条件からの寄与を含みます。H*u = R は、ディリクレタイプの境界条
% 件を表わします。
%
% つぎの形式も使うことができます。
%   
%    [Q,G,H,R] = ASSEMB(B,P,E,U0)
%    [Q,G,H,R] = ASSEMB(B,P,E,U0,TIME)
%    [Q,G,H,R] = ASSEMB(B,P,E,U0,TIME,SDL)
%    [Q,G,H,R] = ASSEMB(B,P,E,TIME)
%    [Q,G,H,R] = ASSEMB(B,P,E,TIME,SDL)
%
% 入力パラメータ B, P, E, U0, TIME, SDL は、ASSMEPDE での入力パラメータ
% と同じ意味をもちます。
%
% 参考   ASSEMPDE, PDEBOUND



%       Copyright 1994-2001 The MathWorks, Inc.
