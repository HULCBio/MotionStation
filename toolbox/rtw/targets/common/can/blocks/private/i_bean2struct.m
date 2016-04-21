function str = i_bean2struct(bean,fields)
%I_BEAN2STRUCT
% Turns the properties of a bean into a struct

%   Copyright 2001-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $
%   $Date: 2004/04/19 01:19:32 $

   str = [];
   for i=1:length(fields)
      getV = i_bean_get(bean,fields{i});
      str = setfield(str,fields{i},getV);
   end

