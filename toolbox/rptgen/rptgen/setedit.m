function setedit(varargin)
%SETEDIT  Report Explorer GUI 
%   SETEDIT starts the Report Explorer GUI.
%
%   SETEDIT <filename> starts the Report Explorer with the
%   specified file.  If <filename> does not exist, it will start
%   with a blank file of that name.
%
%   See also RPTLIST, REPORT, RPTCONVERT
 
%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/03/21 22:24:34 $

if (RptgenML.v1mode)
	%check to see if the editor is already open
	sfeHandle=findall(allchild(0),'Tag','Setup File Editor');

	if ~isempty(sfeHandle)
		%if there is an existing setup file editor
		for i=1:length(varargin)
			g=doguiaction(rgstoregui,'OpenFile',varargin{i});
		end
		figure(sfeHandle(1));
	else
		if nargin>0
			g=rptgui(loadsetfile(rptparent,varargin{1}));
		else
			g=rptgui;
		end

		buildui(g);
		for i=2:length(varargin)
			g=doguiaction(rgstoregui,'OpenFile',...
				varargin{i});
		end
	end
else
	RptgenML.explore(varargin{:});
end