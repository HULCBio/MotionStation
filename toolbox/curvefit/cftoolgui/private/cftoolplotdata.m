function cftoolplotdata(dataset, plot, unplotfits) 
%CFTOOLPLOTDATA is a helper function for CFTOOL.
%The DATASET PLOT value is set. If unplotfits is true, find
%all fits that use DATASET and set its plot value to false.

%   $Revision: 1.1.6.2 $  $Date: 2004/03/02 21:46:11 $
%   Copyright 2001-2004 The MathWorks, Inc.

dataset.plot = plot;
if unplotfits && ~plot %unplot associated fits.
    name = dataset.name;
    fitdb=getfitdb;
    child=down(fitdb);
    while ~isempty(child)
        if isequal(name, child.dataset)
            child.plot = 0;
            com.mathworks.toolbox.curvefit.FitsManager.getFitsManager.fitChanged(java(child));
        end
        child=right(child);
    end
end
