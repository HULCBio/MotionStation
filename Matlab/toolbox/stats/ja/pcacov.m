% PCACOV   共分散行列を使った主成分分析
%
% [PC, LATENT, EXPLAINED] = PCACOV(X) は、共分散行列 X を使って、主成分を 
% PC に、X の共分散行列の固有値を LATENT に、個々の固有値で説明される
% 観測値の中のトータルの分散の割合(百分率)を EXPLAINED に出力します。


%   B. Jones 3-17-94
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:14:35 $
