% function out = sisorat(freq,gain)
% または
% function out = sisorat(data_g)
% 
% 周波数FREQで、ゲインがGAINである1次の安定な伝達関数を求めます。入力引
% 数が1つの場合、DATA_Gは1行1列のVARYING行列で、データ点を1つもちます。
% 独立変数はFREQと考えられ、行列の値はGAINと考えられます。生成した伝達関
% 数は、一定の大きさの交差周波数をもちます。
%
% 参考: DYPERT, MU, RANDEL, UNWRAPP.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
