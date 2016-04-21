function s = fpbhelp(blkname)
% FPBHELP Points Web browser to the HTML help file
%          corresponding to Simulink Fixed-Point.

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.19.2.1 $ 
% $Date: 2004/04/13 00:34:28 $

d = docroot;
if isempty(d),
    % Help system not present:
    warning('fpbhelp:NoDocRootFound', ...
            'Could not locate docroot. Type help docroot to configure your documentation settings');
    s = [matlabroot '/help/begin_here.html'];
else
  if isempty(blkname) | isequal(blkname,'fxptdlg')
    if ~isempty(which('autofixexp')) % Locates if Simulink Fixed-Point is installed
      s = ['file:///' docroot '/toolbox/simulink/slref/fxptdlg.html#64593'];
    else
      s = ['file:///' docroot '/toolbox/simulink/ug/working_with_data5.html'];
    end
  else
    s = [matlabroot '/help/begin_here.html'];
  end
end