% ASSEMA   剛性マトリックスと質量マトリックスと右辺ベクトルを組み立てま
%          す。
%
% [K,M,F1] = ASSEMA(P,T,C,A,F) は、剛性マトリックス K と質量マトリックス
% M と右辺ベクトル F1 を組み立てます。
%
% つぎの形式も使うことができます。
% 
%    [K,M,F1] = ASSEMA(P,T,C,A,F,U0)
%    [K,M,F1] = ASSEMA(P,T,C,A,F,U0,TIME)
%    [K,M,F1] = ASSEMA(P,T,C,A,F,U0,TIME,SDL)
%    [K,M,F1] = ASSEMA(P,T,C,A,F,TIME)
%    [K,M,F1] = ASSEMA(P,T,C,A,F,TIME,SDL)
%
% 入力パラメータ P, T, C, A, F, U0, TIME, SDL は、ASSMEPDE での入力パラ
% メータと同じ意味をもちます。
%
% 参考   ASSEMPDE



%       Copyright 1994-2001 The MathWorks, Inc.
