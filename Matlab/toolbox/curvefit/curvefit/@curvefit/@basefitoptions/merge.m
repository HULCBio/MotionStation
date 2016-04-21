function opts = merge(oldopts,newopts)
% MERGE Combine two basefitoptions objects.
%  F = MERGE(OLDF,NEWF) combines an existing fitoptions object OLDF
%  with a new fitoptions object NEWF. If OLDF and NEWF have the same 'Method',
%  any parameters in NEWF with non-empty values override the corresponding old 
%  parameters in OLDF. If OLDF and NEWF have different 'Method' values, F will 
%  have the same Method as OLDF, and only the fields 'Normalize', 'Exclude', 
%  and 'Weights' of NEWF will override the OLDF fields. 

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.4.2.1 $  $Date: 2004/02/01 21:41:05 $

if ~isequal(oldopts.Method,newopts.Method)
    s =  {'Normalize'; 'Exclude';  'Weights' };
else
    s = fields(newopts);
end    

opts = copy(oldopts);
for i = 1:length(s)
    val = get(newopts,s{i});
    if ~isempty(val)
        set(opts,s{i},val);
    end
end
