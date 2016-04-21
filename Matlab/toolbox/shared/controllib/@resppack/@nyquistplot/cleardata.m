function cleardata(this,Domain)
%CLEARDATA  Clear dependent data from all data objects.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:21:41 $
if strcmpi(Domain,'Frequency')
    % Clear mag and phase data (will force reevaluation of the DataFcn)
    if ~isempty(this.Responses)
        for r=find(this.Responses,'-not','DataSrc',[],'-not','DataFcn',[])'
            clear(r.Data)
        end
    end
end