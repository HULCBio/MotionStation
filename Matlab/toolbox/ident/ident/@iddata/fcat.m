function idfn = fcat(varargin)
%IDDATA/FCAT Concatanation of Frequency Domain IDDATA sets along the frequency dimension
%   DC = FCAT(D1,D2,...Dn)
%   
%   D1, D2 ... are IDDATA objects, all with the same number of inputs and outputs.
%   MC is an IDDATA obhect that contains all the data of D1, D2, ...
%   
%   See also IDDATA/VERTCAT.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/10 23:15:48 $


if ischar(varargin{end})
    srt = 0;
    varargin = varargin(1:end-1);
else
    srt = 1;
end

idfn = vertcat(varargin{:});
