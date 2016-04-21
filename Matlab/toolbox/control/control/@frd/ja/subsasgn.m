% SUBSASGN   LTIオブジェクトに対する添字付き割り当て
%
% つぎの割り当て操作は、任意のLTIモデル SYS に対して適用されます。
%   SYS(Outputs,Inputs) = RHS  I/O チャンネルのサブセットの割り当て
%   SYS.Fieldname = RHS        SET(SYS,'Fieldname',RHS) と等価
% 左辺の表現は、SYS(1,[2 3]).inputname = 'u' や、
% SYS.ResponseData(1) = [ ... ] のように適当な添字付き参照を続けることが
% できます。
%
% LTIモデルの配列に対して、インデックス付き割り当ては、つぎの書式を使い
% ます。
% 
%   SYS(Outputs,Inputs,j1,...,jk) = RHS
% 
% ここで、k は配列の次元数です(入出力の次元に加わる)。
%
% 参考 : SET, SUBSREF, LTIMODELS.


%   Author(s): S. Almy, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
