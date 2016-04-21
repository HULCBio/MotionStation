function Hd = findfilters(varargin)
%FINDFILTERS Finds filters in the input vector

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.3 $  $Date: 2004/04/13 00:31:46 $

Hd   = {};
b    = [];

for indx = 1:length(varargin)
    
    % If the input is a filter, use it.
    if isa(varargin{indx}, 'dfilt.basefilter') | isa(varargin{indx}, 'qfilt'),
        
        % If we have something in b, create the filter using it
        if ~isempty(b),
            Hd{end+1} = dfilt.dffir(b);
            b = [];
        end
        for jndx = 1:length(varargin{indx})
            Hd{end + 1} = varargin{indx}(jndx);
        end
    elseif isa(varargin{indx}, 'dfilt.dfiltwfs'),
        % If we have something in b, create the filter using it
        if ~isempty(b),
            Hd{end+1} = dfilt.dffir(b);
            b = [];
        end
        Hd{end + 1} = varargin{indx};
        
    elseif isnumeric(varargin{indx})
        
        % If the input is numeric it is either a num or a den
        if isempty(b),
            b = varargin{indx};
        else
            
            % If b is not empty the new input must be the den
            Hd{end+1} = dfilt.df2t(b, varargin{indx});
            b = [];
        end
    elseif ~isempty(b),
        
        % If we find something else and we have a num, it must be FIR
        Hd{end+1} = dfilt.dffir(b);
        b = [];
    end
end

if ~isempty(b),
    Hd{end+1} = dfilt.dffir(b);
end

% [EOF]
