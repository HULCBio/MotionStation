function mpcsimopt = subsasgn(mpcsimopt,Struct,rhs)
%SUBSREF  MPCSIMOPT property management in assignment operation
%
%   mpcsimopt.Field = Value sets the 'Field' property of the MPCSIMOPT object mpcsimopt 
%   to the value Value. Is equivalent to SET(mpcsimopt,'Field',Value)
%

%   Author: A. Bemporad
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2003/12/04 01:33:15 $   

if nargin==1,
    return
elseif ~isa(mpcsimopt,'mpcsimopt') & ~isempty(mpcsimopt)
    mpcsimopt = builtin('subsasgn',mpcsimopt,Struct,rhs);
    return
end
StructL = length(Struct);

% Peel off first layer of subassignment
switch Struct(1).type
    case '.'
        % Assignment of the form mpcsimopt.fieldname(...)=rhs
        FieldName = Struct(1).subs;
        try
            if StructL==1,
                FieldValue = rhs;
            else
                FieldValue = subsasgn(get(mpcsimopt,FieldName),Struct(2:end),rhs);
            end
            set(mpcsimopt,FieldName,FieldValue)
        catch
            rethrow(lasterror)
        end
    otherwise
         error('mpc:mpcsimoptsubsasgn:support','This type of referencing is not supported for MPCSIMOPT objects.')
end