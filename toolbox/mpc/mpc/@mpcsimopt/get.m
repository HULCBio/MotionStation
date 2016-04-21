function Value = get(mpcsimopt,Property)
%GET  Access/query MPCSIMOPT property values.
%
%   VALUE = GET(mpcsimopt,'PropertyName') returns the value of the 
%   specified property of the mpcsimopt object mpcsimopt.  An equivalent
%   syntax is 
%       VALUE = mpcsimopt.PropertyName .
%   
%   STRUCT = GET(mpcsimopt) converts the mpcsimopt object mpcsimopt into 
%   a structure STRUCT with the property names as field names and
%   the property values as field values.
%
%   Without left-hand argument, GET(mpcsimopt) displays all properties 
%   of mpcsimopt and their values. 
%
%   See also SET.

%   Author: A. Bemporad, P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2003/12/04 01:33:08 $   

% Generic GET method.
% Uses the object-specific methods PNAMES and PVALUES
% to get the list of all public properties and their
% values (PNAMES and PVALUES must be defined for each 
% particular child object)

ni = nargin;
aux=nargchk(1,2,ni);
if ~isempty(aux),
    error('mpc:mpcsimoptget:nargin',aux.message);
end

if ni==2,
    % GET(mpcsimopt,'Property') or GET(mpcsimopt,{'Prop1','Prop2',...})
    CharProp = ischar(Property);
    if CharProp,
        Property = {Property};
    elseif ~iscellstr(Property)
        error('mpc:mpcsimoptget:name','Property name must be a string or a cell vector of strings.')
    end
    
    % Get all public properties
    AllProps = pnames(mpcsimopt);
    
    % Loop over each queried property 
    Nq = prod(size(Property)); 
    Value = cell(1,Nq);
    for i=1:Nq,
        % Find match for k-th property name and get corresponding value
        % RE: a) Must include all properties to detect multiple hits
        %     b) Limit comparison to first 7 chars
        try 
            propstr=lower(Property{i});
            Value{i} = pvget(mpcsimopt,pnmatch(propstr,AllProps,7));
        catch
            rethrow(lasterror)
        end
    end
    
    % Strip cell header if PROPERTY was a string
    if CharProp,
        Value = Value{1};
    end
    
elseif nargout,
    % STRUCT = GET(mpcsimopt)
    Value = cell2struct(pvget(mpcsimopt),pnames(mpcsimopt),1);
    
else
    % GET(mpcsimopt)
    PropStr = pnames(mpcsimopt);
    [junk,ValStr] = pvget(mpcsimopt);
    disp(mpc_pvformat(PropStr,ValStr))
    
end
