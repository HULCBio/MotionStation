%  [num,den]=frfit(omega,fresp,r,weight)
%  sys = frfit(omega,fresp,r,weight)
%
% MAGSHAPE/MRFITから呼び出されます。
%
% 次数Rの安定な伝達関数
% 
%                G(s) = NUM(s)/DEN(s)
% 
% によって周波数応答のデータ点を近似します。
%
% 補間は、Chebychev多項式を使用します。OMEGAは周波数ベクトルで、FRESPは
% 周波数での応答を含みます。周波数重み補間は、周波数重みベクトルWEIGHTを
% 設定することによって行われます。
%
% 参考：    MAGSHAPE, MRFIT.



% Copyright 1995-2002 The MathWorks, Inc. 
