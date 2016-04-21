% PDEVAL  PDEPEの出力解と微係数を計算
%
% 配列 SOL はPDEPE から出力されるとき、UI = SOL(j,:,i) は、時間 T(j) と
% メッシュ点 X においてPDEの解の要素 i を近似します。 
% [UOUT,DUOUTDX] = PDEVAL(M,X,UI,XOUT) は、点 XOUT の配列において
% 近似と偏微係数Dui/Dxを計算し、それらを UOUT と DUOUTDX に出力します。  
%
% 参考 ： PDEPE.


%   Lawrence F. Shampine and Jacek Kierzenka
%   Copyright 1984-2003 The MathWorks, Inc. 
