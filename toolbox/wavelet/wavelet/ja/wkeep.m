% WKEEP  　ベクトルまたは行列の一部を保持
% 
% ベクトルに対して、
% Y = WKEEP(X,L,OPT) は、ベクトル X からベクトル Y を抽出します。L は結果 Y の長
% さになります。OPT = 'c' ('l' 、'r') の場合、 Y は X の中央部(それぞれ左側、右
% 側)から抽出します。Y = WKEEP(X,L,FIRST) は、ベクトル X(FIRST:FIRST+L-1) を出力
% します。
%
% Y = WKEEP(X,L) は、Y = WKEEP(X,L,'c') と等価です。
%
% 行列に対して、
% Y = WKEEP(X,S) は、行列 X の中央部を抽出します。S は Y の大きさです。Y = WKEEP
% (X,S,[FIRSTR,FIRSTC]) は、X(FIRSTR,FIRSTC) から始まる S の大きさの行列 X の小
% 行列を抽出します。



%   Copyright 1995-2002 The MathWorks, Inc.
