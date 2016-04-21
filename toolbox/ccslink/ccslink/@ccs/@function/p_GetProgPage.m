function page = p_GetProgPage(ff)
% (Private) Returns the Prog page for a specific processor.

% Copyright 2004 The MathWorks, Inc.

if strcmp(ff.procsubfamily,'C6x'),          
    page = 0; % no paging
elseif strcmp(ff.procsubfamily,'C54x'),     
    page = 0; % Prog page
elseif strcmp(ff.procsubfamily,'C55x'),     
    page = 0; % Prog page
    %% TO DO - check if this is correct
elseif strcmp(ff.procsubfamily,'C28x'),
    page = 0; % Prog page
else 
    error(generateccsmsgid('ProcNotSupported'),...
    ['The Function class does not support the ''' ff.procsubfamily ''' processor.']);
end

% [EOF] p_GetProgPage.m