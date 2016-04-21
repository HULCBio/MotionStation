function rmhighlight(reqsys, doc, modelname, color);
%RMHIGHLIGHT highlights blocks with requirements.
%   RMHIGHLIGHT(REQSYS, DOC, MODELNAME, COLOR) finds all
%   blocks that have requirements and highlights them.
%

%   Author(s): M. Greenstein, 02/24/99
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $   $Date: 2004/04/15 00:36:34 $

[reqitems, blktypes, itemnames] = rmlinked(reqsys, doc, modelname);
for i = 1:length(reqitems)
    try
        if (exist('color') & ~isempty('color'))
            set_param(reqitems{i}, 'HiliteAncestors', color);            
        end
    catch
    end
end


