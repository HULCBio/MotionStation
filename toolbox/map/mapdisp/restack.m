function restack(hobj,action)

%RESTACK restacks objects within the axes
%
%  RESTACK(h,position) changes the stacking order of the object h within 
%  the axes.  h can be a handle or vector of handles to graphics objects, or 
%  h can be a name string recognized by HANDLEM. Recognized position strings 
%  are 'top','bottom','bot','up' or 'down'. RESTACK permutes the order of the 
%  children of the axes.
%
%  See also MOBJECTS, ZDATAM

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.6.4.1 $  $Date: 2003/08/01 18:22:32 $

% handle hidden children

% Check for recognized actions

if nargin ~= 2; error('Incorrect number of arguments'); end

actions = {'top','bottom','bot','up','down'};

if isempty(strmatch(action,actions,'exact'))
	error('Unknown RESTACK option')
end

% Get the handle of the target object
if ~ishandle(hobj)
	hobj = handlem(hobj);
end

if isempty(hobj); return; end 
	
% Get the handles of the children of the axes
children = get(gca,'Children');

% identify the location of the target object within the children
[ignored,objpos] 	= intersect(children,hobj);
objpos = sort(objpos);

% identify the locations everything besides the target object
[ignored,notobjpos] 	= setxor(children,hobj);
notobjpos = sort(notobjpos);

% reorder the children 
switch action
case 'top'	
	newchildren = [children(objpos(:)); children(notobjpos(:))];
case {'bottom','bot'}
	newchildren = [children(notobjpos(:)); children(objpos(:))];
case 'down'	
	topobj = max(objpos);
	newchildren = [	children( notobjpos( notobjpos(:)<= (topobj+1) ) ); ...
					children(objpos(:)); ...
					children( notobjpos( notobjpos(:)>topobj+1 ) ) ];

case 'up'	
	botobj = min(objpos);
	newchildren = [	children( notobjpos( notobjpos(:)< (botobj-1) ) ); ...
					children(objpos(:)); ...
					children( notobjpos( notobjpos(:)>= (botobj-1) ) ) ];

end

set(gca,'Children',newchildren)

