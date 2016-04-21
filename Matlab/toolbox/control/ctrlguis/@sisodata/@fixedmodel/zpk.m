function sys = zpk(ModelData)
%ZPK   Get ZPK representation of model.
%
%   SYS = MODEL.ZPK returns the zero/pole/gain representation of MODEL.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/10 04:55:02 $

sys = zpk(ModelData.Zero,ModelData.Pole,ModelData.Gain,...
	get(ModelData.Model,'Ts'));
     
