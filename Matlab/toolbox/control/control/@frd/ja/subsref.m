% SUBSREF   LTIオブジェクトに対する添字付き参照
%
% つぎの参照操作は、任意のLTIモデル SYS に適用できます。
%   SYS(Outputs,Inputs)   I/O チャンネルのサブセットの選択
%   SYS.Fieldname         GET(SYS,'Fieldname') と等価
% これらの表現は、SYS(1,[2 3]).inputname や SYS.Frequency(1) のように
% 適切な添字付き参照を続けることができます。
%
% LTI配列に対して、参照は、つぎの形式を取ります。
% 
%   SYS(Outputs,Inputs,j1,...,jk)
% 
% ここで、k は、追加の次元数です(通常の入出力の次元に加わる)。LTI配列の
% (j1,...,jk)モデルにアクセスするには、つぎの書式を利用してください。
% 
%   SYS(:,:,j1,...,jk)
%
% 参考 : GET, FRDATA, SUBSASGN, LTIMODELS.


%   Author(s): P. Gahinet, S. Almy
%   Copyright 1986-2002 The MathWorks, Inc. 
