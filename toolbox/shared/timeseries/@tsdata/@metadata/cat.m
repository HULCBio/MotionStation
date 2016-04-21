function outmetadata = cat(in1, in2, action)
%CAT For concatonating metadata in overloaded concatonation
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:33:20 $

% Merge Units
outordunits = '';
if ~isempty(in1.Units) && ~isempty(in2.Units) && strcmp(in1.Units,in2.Units)
      outordunits = in1.Units;
end

% Merge Scales
outordscale = [];
if ~isempty(in1.Scale) && ~isempty(in2.Scale) && ...
        length(in1.Scale)==2 && length(in2.Scale)==2 && isequal(in1.Scale,in2.Scale)
             outordscale = in1.Scale;
end

% Merge offsets
outordoffset = [];
if ~isempty(in1.Offset) && ~isempty(in2.Offset) && ...
        length(in1.Offset)==1 && length(in2.Offset)==1 && isequal(in1.Offset,in2.Offset)
               outordoffset = in1.Offset;
end

% Merge interpolation. Differing methods => linear
if isequal(in1.Interpolation.Fhandle,in2.Interpolation.Fhandle)
    outordinterp = copy(in1.Interpolation);
else
    outordinterp = tsdata.interpolation('zoh');
end

% Merge GridFirst
outgridfirst = true;
if in1.GridFirst == in2.GridFirst
    outgridfirst = in1.GridFirst;
end

outmetadata = tsdata.metadata;
set(outmetadata,'Units',outordunits,'Scale',outordscale,'Offset',outordoffset,...
    'Interpolation',outordinterp,'Name','Data','GridFirst', outgridfirst);


