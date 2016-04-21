function MPCobj = subsasgn(MPCobj,Struct,rhs)
%SUBSREF  MPC property management in assignment operation
%
%   MPCOBJ.Field = Value sets the 'Field' property of the MPC object MPCOBJ
%   to the value Value. Is equivalent to SET(MPCOBJ,'Field',Value)
%

%   Author: A. Bemporad
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.10.3 $  $Date: 2003/12/04 01:33:01 $


if nargin==1,
    return
elseif ~isa(MPCobj,'mpc') & ~isempty(MPCobj)
    MPCobj = builtin('subsasgn',MPCobj,Struct,rhs);
    return
end
StructL = length(Struct);

% Peel off first layer of subassignment
switch Struct(1).type
    case '.'
        % Assignment of the form MPCobj.fieldname(...)=rhs
        FieldName = Struct(1).subs;
        try
            if StructL==1,
                FieldValue = rhs;
            else
                FieldValue = subsasgn(get(MPCobj,FieldName),Struct(2:end),rhs);
            end
            set(MPCobj,FieldName,FieldValue)
        catch
            rethrow(lasterror)
        end
    otherwise
         error('mpc:subsasgn:support','This type of referencing is not supported for MPC objects.')
        %error('mpc:subsasgn:support',sprintf('Unknown type: %s',Struct(1).type));
end

% Note: possible fields having wrong case are appended anyways below.
% For the structure Model, duplicates are correctly handled by
% MPC_PRECHKMODEL, in particular the last appended field dominates over
% duplicates.