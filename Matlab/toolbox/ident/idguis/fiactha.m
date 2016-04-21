function [index,cindex]=fiactha(hh)
%FIACTHA Finds indices of handles HH that are active uicontrols ('Value'==1).

%   L. Ljung 4-4-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2001/04/06 14:22:32 $

index=[];cindex=[];
for k=1:length(hh)
	try
		if get(hh(k),'value'),
			index=[index,k];
		else 
			cindex=[cindex,k];
		end
	catch
		cindex=[cindex,k];
	end
end