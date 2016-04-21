function vqplot_entropy(hplotentropy, entropy_array) 
% plots entropy data, sets grid, markers, labels
% hplotentropy = handles.plotEntropyIter;

%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:18:01 $

     Xgrid_plotEntropyIter = get(hplotentropy,'Xgrid');
     Ygrid_plotEntropyIter = get(hplotentropy,'Ygrid');
     axes(hplotentropy);
	
     h_line=plot(entropy_array);
     xlabel('Number of Iterations');
     ylabel('Entropy');
     % always call after setting axes, xlabel and ylabel, and plot command
     set(h_line,'ButtonDownFcn',@setdatamarkers);
     set(hplotentropy,'Xgrid',Xgrid_plotEntropyIter);
     set(hplotentropy,'Ygrid',Ygrid_plotEntropyIter);
     
% [EOF]
