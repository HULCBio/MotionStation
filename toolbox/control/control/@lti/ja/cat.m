% CAT   LTIモデルの結合
%
%
% SYS = CAT(DIM,SYS1,SYS2,...) は、LTIモデルを次元 DIM に従って並べます。
% 値 DIM = 1,2 は、出力と入力の次数に対応して、値 DIM = 3,4,... は、LTI配列の
% 次元1,2,....に対応しています。
%
% たとえば、
%   * CAT(1,SYS1,SYS2) は、[SYS1 ; SYS2] と等価です。 
%   * CAT(2,SYS1,SYS2) は、[SYS1 , SYS2] と等価です。 
%   * CAT(4,SYS1,SYS2) は、STACK(2,SYS1,SYS2) と等価です。
%
% 参考 : HORZCAT, VERTCAT, STACK, APPEND, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
