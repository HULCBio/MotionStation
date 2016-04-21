function bfitclearappdata(obj)
% BFITCLEARAPPDATA is used to remove Basic Fitting and Data Stats 
% application data from Basic Fitting and Data Stats objects (OBJ). 
% It should be used only by private Basic Fitting and Data Stats 
% functions. 

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/10 23:26:23 $

ad = getappdata(obj);
names = fieldnames(ad);

% decrement figure's Data Counter if the line being removed
% is the last line in the legend. That way removing and
% adding while changing x and y data is a no-op.
try
  dname = ad.bfit_dataname;
  if strncmp(dname,'data ',5)
    n = str2num(dname(6:end));
    fig = ancestor(obj,'figure');
    countstart = getappdata(fig,'Basic_Fit_Data_Counter');
    if countstart == n+1
      setappdata(fig,'Basic_Fit_Data_Counter',countstart-1);
    end
  end
end

for i = 1:length(names)
	if ( strncmp(names{i}, 'bfit', 4) | ...
		 strncmp(names{i}, 'Basic_Fit_', 10) | ...
		 strncmp(names{i}, 'Data_Stats_', 11))
		rmappdata(obj, names{i});
	end
end
