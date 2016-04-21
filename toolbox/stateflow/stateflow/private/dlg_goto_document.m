function dlg_goto_document(objectId)
%DLG_GOTO_DOCUMENT( OBJECTID )

%   E.Mehran Mestchian
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.12.2.1 $  $Date: 2004/04/15 00:56:58 $
	if ~sf('ishandle',objectId)
		return;
	end

	if ~sf('IsIced',objectId)
	   dlg_edit_field( 'apply', objectId, '.document', 'DOCUMENT','',0);
	end

	document = sf('get',objectId,'.document');
	if isempty(document)
      h = findobj('Type','figure','Tag','STAEFLOW DOCUMENT LINK');
      if isempty(h)
         h = msgbox(...
            {'Stateflow document link can be a web URL';...
             'address or a general MATLAB command.';...
             '';...
             'Some examples are:';...
             '    www.mathworks.com';...
             '    http://www.mathworks.com';...
             '    http://spec/data/speed.html';...
             '    mailto:email_address';...
             '    edit /spec/data/speed.txt';...
            },'No Document link specified.');
         set(h,'Tag','STAEFLOW DOCUMENT LINK');
      else
         figure(h);
      end
		return;
	end
	if ~isempty([regexp(document,'^\s*[a-zA-Z]+:', 'once') regexp(document,'^\s*www\.','once')])
		web(document);
		return;
	end
	eval(document);

