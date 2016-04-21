function outmetadata = times(in1, in2)
%TIMES For managing metadata in overloaded multiplication
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:33:28 $

% Merge Scales
outordscale = [];
if ~isempty(in1.Scale) && ~isempty(in2.Scale) && ...
        length(in1.Scale)==2 && length(in2.Scale)==2
           outordscale = in1.Scale.*in2.Scale;
end

%% Merge grid orientation
outgridfirst = true;
if in1.GridFirst==in2.GridFirst
    outgridfirst = in1.GridFirst;
end

% Merge offsets
outordoffset = [];
if ~isempty(in1.Offset) && ~isempty(in2.Offset) && ...
        length(in1.Offset)==1 && length(in2.Offset)==1
           outordoffset = in1.Offset*in2.Offset;
end

% Merge interpolation. Differing methods => linear
if isequal(in1.Interpolation.Fhandle,in2.Interpolation.Fhandle)
    outordinterp = copy(in1.Interpolation);
else
    outordinterp = tsdata.interpolation('zoh');
end

outmetadata = tsdata.metadata;
set(outmetadata,'Scale',outordscale,'Offset',outordoffset,...
    'Interpolation',outordinterp,'Name','Data','GridFirst',outgridfirst);


