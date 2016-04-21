%    LOW-LEVEL FUNCTION   [A,B,flag]=nncoeff(t,data,task)
%
% LMI項Tに関連する係数を抽出。
%
% TASK=0 (変数項AXB)             -> MA2VE形式でAとB'を出力
% TASK=1 (スカラ変数項 x*(A*B) ) -> MA2VE形式でA*Bを出力
% TASK=2 (アウターファクターN)   -> MA2VE形式でN'を出力(Tにストアされる
%                                   ように)
% 
% 対角ブロックの自己結合項に対して、FLAG=1となります。
%

% Copyright 1995-2001 The MathWorks, Inc. 
