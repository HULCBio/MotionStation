function result = subsref(mpcsimopt,Struct)
%SUBSREF  Subscripted reference for mpcsimopt objects.
%
%   The following reference operation can be applied to any 
%   mpcsimopt object: 
%      mpcsimopt.Fieldname  equivalent to GET(mpcsimopt,'Fieldname')
%   These expressions can be followed by any valid subscripted
%   reference of the result, as in  SYS(1,[2 3]).inputname  or
%   SYS.num{1,1}.
%
%
%   See also GET.

%   Author: A. Bemporad
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2003/12/04 01:33:16 $   


% Effect on mpcsimopt properties: all inherited

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
         result = get(mpcsimopt,Struct(1).subs);   
      else
         %Struct(2).subs=names(Struct(1).subs,Struct(2).subs);
         result = subsref(get(mpcsimopt,Struct(1).subs),Struct(2:end));
      end
   catch
      error(lasterr)
   end
otherwise
   error('mpc:mpcsimoptsubsref:ref',['Unknown reference type: ' Struct(1).type])
end
