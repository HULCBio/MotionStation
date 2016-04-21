% CSVWRITE   カンマで区切られた値のファイルの書き出し
% 
% CSVWRITE(FILENAME,M) は、行列 M を カンマで区切った値として FILENAME 
% に書き出します。
%
% CSVWRITE(FILENAME,M,R,C) は、行列 M をファイル内でのオフセット行 R、
% 列 C から書き出します。R と C はゼロを基準としているので、R = C = 0 は
% ファイルの最初の数値を指定します。
%
% 参考：CSVREAD, DLMREAD, DLMWRITE, WK1READ, WK1WRITE.


%   Brian M. Bourgault 10/22/93
%   Copyright 1984-2002 The MathWorks, Inc. 
