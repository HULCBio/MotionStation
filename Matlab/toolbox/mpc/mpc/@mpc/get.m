function Value = get(MPCobj,Property)
%GET  Access/query MPC property values.
%
%   VALUE = GET(MPCOBJ,'PropertyName') returns the value of the 
%   specified property of the MPC object MPCOBJ.  An equivalent
%   syntax is 
%     VALUE = MPC.PropertyName .
% 
%   STRUCT = GET(MPCOBJ) converts the MPC object MPCOBJ into 
%   a structure STRUCT with the property names as field names and
%   the property values as field values.
%
%   Without left-hand argument, GET(MPCOBJ) displays all properties 
%   of MPCOBJ and their values.  Type HELP MPCPROPS for more details
%   on MPC properties.
%
%   See also SET, MPCPROPS.

%   Author: A. Bemporad, P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.10.3 $  $Date: 2003/12/04 01:32:38 $   


% Generic GET method.
% Uses the object-specific methods PNAMES and PVALUES
% to get the list of all public properties and their
% values (PNAMES and PVALUES must be defined for each 
% particular child object)

ni = nargin;
aux=nargchk(1,2,ni);
if ~isempty(aux),
    error('mpc:get:nargin',aux.message);
end

if ni==2,
    % GET(MPCobj,'Property') or GET(MPCobj,{'Prop1','Prop2',...})
    CharProp = ischar(Property);
    if CharProp,
        Property = {Property};
    elseif ~iscellstr(Property)
        error('mpc:get:name','Property name must be a string or a cell vector of strings.')
    end
    
    % Get all public properties
    AllProps = pnames(MPCobj);
    
    % Loop over each queried property 
    Nq = prod(size(Property)); 
    Value = cell(1,Nq);
    for i=1:Nq,
        % Find match for k-th property name and get corresponding value
        % RE: a) Must include all properties to detect multiple hits
        %     b) Limit comparison to first 7 chars
        try 
            propstr=lower(Property{i});
            % Handle multiple names
            if strcmp(propstr,'mv') | strcmp(propstr,'input'),
                propstr='manipulatedvariables';
            elseif strcmp(propstr,'ov') | strcmp(propstr,'controlled'),
                propstr='outputvariables';
            elseif strcmp(propstr,'dv'),
                propstr='disturbancevariables';
            end
            strmatch=pnmatch(propstr,AllProps,7);
            Value{i} = pvget(MPCobj,strmatch);
        catch
            rethrow(lasterror)
        end
        
        % Change history field to DATESTR format
        if strcmp(strmatch,'History'),
            Value{i}=datestr(Value{i});
        end
            
    end
    
    % Strip cell header if PROPERTY was a string
    if CharProp,
        Value = Value{1};
    end
    
elseif nargout,
    % STRUCT = GET(MPCobj)
    Value = cell2struct(pvget(MPCobj),pnames(MPCobj),1);
    
else
    % GET(MPCobj)
    PropStr = pnames(MPCobj);
    [junk,ValStr] = pvget(MPCobj);
    disp(mpc_pvformat(PropStr,ValStr))
    
end
