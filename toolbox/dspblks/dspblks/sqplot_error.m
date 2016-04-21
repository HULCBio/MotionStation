function sqplot_error(hploterror, err_array) 
% plots error data, sets grid, markers, labels
% hploterror = handles.plotErrIter;

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/25 22:04:17 $

     Xgrid_plotErrIter = get(hploterror,'Xgrid');
     Ygrid_plotErrIter = get(hploterror,'Ygrid');
     axes(hploterror);
	
     h_line=plot(err_array);
     xlabel('Number of Iterations');
     ylabel('Mean Square Error');
     % always call after setting axes, xlabel and ylabel, and plot command
     set(h_line,'ButtonDownFcn',@setdatamarkers);
     set(hploterror,'Xgrid',Xgrid_plotErrIter);
     set(hploterror,'Ygrid',Ygrid_plotErrIter);
     
% [EOF]
