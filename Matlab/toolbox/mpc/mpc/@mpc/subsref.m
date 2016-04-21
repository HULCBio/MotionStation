function result = subsref(MPCobj,Struct)
%SUBSREF  Subscripted reference for MPC objects.
%
%   The following reference operation can be applied to any 
%   MPC controller MPCOBJ: 
%      MPCOBJ.Fieldname  equivalent to GET(MPCOBJ,'Fieldname')
%   These expressions can be followed by any valid subscripted
%   reference of the result, as in  SYS(1,[2 3]).inputname  or
%   SYS.num{1,1}.
%
%
%   See also GET.

%   Author: A. Bemporad
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.10.3 $  $Date: 2003/12/04 01:33:02 $   


% Effect on MPC properties: all inherited

ni = nargin;
if ni==1,
   result = sys;
   return
end
StructL = length(Struct);

% Peel off first layer of subreferencing
switch Struct(1).type
case '.'
   
   % The first subreference is of the form sys.fieldname
   % The output is a piece of one of the system properties
   try
      if StructL==1,
         result = get(MPCobj,Struct(1).subs);   
      else
         %Struct(2).subs=names(Struct(1).subs,Struct(2).subs);
         result = subsref(get(MPCobj,Struct(1).subs),Struct(2:end));
      end
   catch
      error(lasterr)
   end
otherwise
   error('mpc:subsref:ref',['Unknown reference type: ' Struct(1).type])
end


% function newField=names(Property,Field)
% 
% switch(lower(Property)),
% case {'manipulatedvariables','mv','manipulated','input'}
%    switch lower(Field)
%    case {'minecr'}
%       newField='MinECR';
%    case {'maxecr'}
%       newField='MaxECR';
%    case {'ratemin'}
%       newField='RateMin';
%    case {'ratemax'}
%       newField='RateMax';
%    case {'rateminecr'}
%       newField='RateMinECR';
%    case {'ratemaxecr'}
%       newField='RateMaxECR';
%    otherwise
%       newField=[upper(Field(1)) lower(Field(2:end))];
%    end      
% case {'outputvariables','ov','controlled','output'}
%    switch lower(Field)
%    case {'minecr'}
%       newField='MinECR';
%    case {'maxecr'}
%       newField='MaxECR';
%    otherwise
%       newField=[upper(Field(1)) lower(Field(2:end))];
%    end      
% case {'disturbancevariables','dv','disturbance'}
%    newField=[upper(Field(1)) lower(Field(2:end))];
% case 'weights'
%    switch lower(Field)
%    case {'mv','manipulated','input'}
%       newField='ManipulatedVariables';
%    case {'ov','controlled','output'}
%       newField='OutputVariables';
%    otherwise
%       newField=Field;
%    end
% case 'mpcdata'
%    switch lower(Field)
%    case 'qp_ready'
%       newField='QP_ready';
%    case 'mpcstruct'
%       newField='MPCstruct';
%    otherwise
%    newField=Field;
% end
% otherwise
%    newField=[upper(Field(1)) lower(Field(2:end))];
% end
