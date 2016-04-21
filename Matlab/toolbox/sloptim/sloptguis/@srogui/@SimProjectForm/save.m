function save(this,SaveIn,SaveAs)
% Save project settings

%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:45:06 $
%   Copyright 1986-2004 The MathWorks, Inc.
this.Dirty = false;
switch SaveIn
   case 'workspace'
      assignin('base',SaveAs,copy(this))
   case 'MAT file'
      OptimProject = this;
      save(SaveAs,'OptimProject')
end
