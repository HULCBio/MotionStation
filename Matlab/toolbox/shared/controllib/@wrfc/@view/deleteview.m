function deleteview(this)
%DELETEVIEW  Deletes @view and associated g-objects.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:27:36 $
for ct = 1:length(this)
  % Delete graphical objects
  h = ghandles(this(ct));
  delete(h(ishandle(h)))
end

% Delete views
delete(this)
