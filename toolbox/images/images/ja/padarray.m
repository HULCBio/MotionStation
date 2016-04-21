% PADARRAY 　配列の付加
%
% B = PADARRAY(A,PADSIZE) は、A のk番目の次元に沿った、PADSIZE(k) の数
% の零を配列 A に付加します。PADSIZE は、正の整数のベクトルです。
%
% B = PADARRAY(A,PADSIZE,PADVAL) は、零の変わりに PADVAL(スカラ)を A の
% 配列に付加します。
%
% B = PADARRAY(A,PADSIZE,PADVAL,DIRECTION) は、文字列 DIRECTION を指定
% された方向に A に付加します。DIRECTION は、以下の文字列の一つを使用
% することができます。
%
% DIRECTION に対する文字列：
%       'pre'         各次元に沿って、最初の配列要素の前に付加
%       'post'        各次元に沿って、最後の配列要素の後に付加
%       'both'        各次元に沿って、最初の配列要素の前と、最後の配列
%                     要素の後に付加
%
デフォルトで、DIRECTION は 'post' です。
% 
% B = PADARRAY(A,PADSIZE,METHOD,DIRECTION) は、設定した METHOD を使って、
% 配列 A に付加します。METHOD は、つぎの文字列の一つを使用することが
% できます。
%
% METHOD に対する文字列：
%     'circular'  -- A を巡回的に繰り返す
%     'replicate' -- A の外側要素を繰り返す
%     'symmetric' -- A を境界を基準に対称に繰り返す
%
% クラスサポート
% -------------
% 一定値を付加する場合、A は、数値または、logical のいずれかです。
% 'circular', 'replicate', または 'symmetric' の手法を用いて付加する
% 場合、A は、任意のクラスです。B は、A と同じクラスです。
%
% 例題
% -------
% ベクトルの最初に3要素を付加します。付加する要素は、配列の鏡像コピーの
% 部分を含んでいます。
%
%       b = padarray([1 2 3 4],3,'symmetric','pre')
%
% 配列の最初の次元の最後に 3要素を付加し、2番目の次元の最後に2要素を付
% 加します。付加する値として、最後の配列要素の値を使います。
%
%       B = padarray([1 2; 3 4],[3 2],'replicate','post')
%
% 3次元配列の各次元に3要素を付加します。各付加する要素は値0です。
%
%       A = [1 2; 3 4];
%       B = [5 6; 7 8];
%       C = cat(3,A,B)
%       D = padarray(C,[3 3],0,'both')
%
% 参考： CIRCSHIFT, IMFILTER.


%   Copyright 1993-2002 The MathWorks, Inc.  
