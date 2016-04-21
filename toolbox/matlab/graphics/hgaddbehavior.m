function hgaddbehavior(h,bh)
% This internal helper function may be removed in a future release.

%HGGETBEHAVIOR Convenience for adding behavior objects
%
%   HGADDBEHAVIOR 
%   With no arguments, a list of all registered behavior
%   objects is generated to the command window.
%
%   HGADDBEHAVIOR(H,BH)
%   Adds behavior object BH to handle H by setting  
%   'Behavior' property for H. Any behavior object with the same 
%   name that is already associated with handle H will be 
%   removed (to avoid duplicate behaivors objects). The 
%   name of the behavior object is defined by its 'Name' 
%   property. 
%
%   Example:
%   % Share behavior objects between handles
%   ax1 = axes;
%   ax2 = axes;
%   bh = hggetbehavior(ax1,'Zoom');
%   hgaddbehavior(ax2,bh); 
%
%   See also hggetbehavior, hgbehaviorfactory.

% Copyright 2003 The MathWorks, Inc.

if nargin==0
    % pretty print list of available behavior objects
    hgbehaviorfactory
    return;
end

for n = 1:length(h)
  localAddBehavior(h(n),bh);
end

%---------------------------------------------%
function localAddBehavior(h,bh)

bb = get(h,'Behavior');

% BUG: Default value is empty structure
if isstruct(bb)
  set(h,'Behavior',[]);
  bb = handle([]);
end

% Check to see if behavior object supports this handle
if ~dosupport(bh,h)
   error('MATLAB:GRAPHICS:HGADDBEHAVIOR',...
         'Behavior object does not support this handle type.')  
end

% Loop through behavior list, remove behavior objects of the same
% type
str1 = get(bh,'Name');
n = 1;
while n <= length(bb)
   str2 = get(bb(n),'Name');
   if isequal(bb(n),bh) || strcmpi(str1,str2)  
       % Remove behavior object
       bb(n) = [];
   else
       n = n+1;
   end
end

set(h,'Behavior',[bb,bh]);
