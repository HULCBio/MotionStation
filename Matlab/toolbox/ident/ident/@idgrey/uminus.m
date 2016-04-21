function sys = uminus(sys)
%UMINUS  Unary minus does not apply to IDGREY models.
%
 

 
%       Copyright 1986-2001 The MathWorks, Inc.
%       $Revision: 1.3 $  $Date: 2001/04/06 14:22:32 $

error(strintf(['Unary minus does not apply to IDGREY models.',...
      '/nApply IDSS first to convert it to IDSS model.']))


