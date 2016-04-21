% PROBOR 確率的 OR
% 
% Y = PROBOR(X) は、X の列の(代数和としても知られている)確率的 OR を出力
% します。X が X = [A; B] のように2行である場合、Y = A + B - AB です。X 
% の行が1つのみである場合、Y = X です。
%
% 例題
%    x = (0:0.1:10);
%    figure('Name','Probabilistic OR','NumberTitle','off');
%    y1 = gaussmf(x,[0.5 4]);
%    y2 = gaussmf(x,[2 7]);
%    yy = probor([y1; y2]);
%    plot(x,[y1; y2; yy])



%	Copyright 1994-2002 The MathWorks, Inc. 
