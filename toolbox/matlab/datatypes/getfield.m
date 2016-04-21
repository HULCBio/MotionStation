function f = getfield(s,varargin)
%GETFIELD Get structure field contents.
%   F = GETFIELD(S,'field') returns the contents of the specified
%   field.  This is equivalent to the syntax F = S.field.
%   S must be a 1-by-1 structure.  
%
%   F = GETFIELD(S,{i,j},'field',{k}) is equivalent to the syntax
%        F = S(i,j).field(k).  
%
%   In other words, F = GETFIELD(S,sub1,sub2,...)  returns the
%   contents of the structure S using the subscripts or field
%   references specified in sub1,sub2,etc.  Each set of subscripts in
%   parentheses must be enclosed in a cell array and passed to
%   GETFIELD as a separate input.  Field references are passed as
%   strings.  
%
%   Note that if the evaluation of the specified subscripts results
%   in a comma separated list, then GETFIELD will return the value
%   corresponding to the first element in the comma separated list.
%
%   For improved performance, when getting the value of a simple 
%   field, use <a href="matlab:helpview([docroot '/techdoc/matlab_prog/matlab_prog.map'],'dynamic_field_names')">dynamic field names</a>.
%
%   See also SETFIELD, ISFIELD, FIELDNAMES, ORDERFIELDS, RMFIELD.
 
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.21.4.3 $  $Date: 2004/04/01 16:12:16 $

% Check for sufficient inputs
if (isempty(varargin))
    error('MATLAB:getfield:InsufficientInputs',...
        'Not enough input arguments.')
end

% The most common case
strField = varargin{1};
if (length(varargin)==1 && ischar(strField))    
    f = s.(deblank(strField)); % deblank field name        
    return
end
    
f = s;           
for i = 1:length(varargin)
    index = varargin{i};
    if (isa(index, 'cell'))
        f = f(index{:});              
    elseif ischar(index)
        
        % Return the first element, if a comma separated list is generated
        try
            f = f.(deblank(index)); % deblank field name                  
        catch
            tmp = cell(1,length(f));
            [tmp{:}] = deal(f.(deblank(index)));
            f = tmp{1};
        end                   
    else
        error('MATLAB:getfield:InvalidType', 'Inputs must be either cell arrays or strings.');
    end
end

