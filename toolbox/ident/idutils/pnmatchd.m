function [Property,imatch] = pnmatchd(Name,PropList,nchars,extend)
%PNMATCHD  Matches property name against property list.
%
%   PROPERTY = PNMATCHD(NAME,PLIST) matches the string NAME 
%   against the list of property names contained in PLIST.
%   If there is a unique match, PROPERTY contains the full 
%   name of the matching property.  Otherwise an error message
%   is issued. PNMATCH uses case-insensitive string comparisons.
%
%   PROPERTY = PNMATCHD(NAME,PLIST,N) limits the string 
%   comparisons to the first N characters.
%
%   See also GET, SET.

 
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.1 $ $Date: 2004/04/10 23:18:48 $

if nargin<4
    extend = 1;
end

if ~ischar(Name) | size(Name,1)>1,
   error('Property names must be single-line strings.')
end

% Set number of characters used for name comparison
%Handle shortcuts
if extend
if strcmp(lower(Name),'u'),Name='InputData';end
if strcmp(lower(Name(1)),'u')
    if strcmp(lower(Name),'un')
        error('Ambiguous property ''un''. Could be ''Units'' or ''UName''.')
    end
   if ~strcmp(lower(Name(2)),'s') 
      if length(Name)<3|(length(Name)>2&~strcmp(lower(Name(1:3)),'uni'))
         Name=['Input',Name(2:end)];
      end
   end
end

if strcmp(lower(Name),'y'),Name='OutputData';end
if strcmp(lower(Name(1)),'y') ,Name=['Output',Name(2:end)];end
end
%s = lower(str);
%ls = length(s);

if nargin<3,
   nchars = length(Name);
else
   nchars = min(nchars,length(Name));
end

% Find all matches
imatch = find(strncmpi(Name,PropList,nchars));

% Get matching property name
switch length(imatch)
case 1
   % Single hit
   Property = PropList{imatch};
   
case 0
   % No hit
   error(sprintf('Invalid property name "%s".',Name))
   
otherwise
   % Multiple hits. Take shortest match provided it is contained
   % in all other matches (Xlim and XlimMode as matches is OK, but 
   % InputName and InputGroup is ambiguous)
   [minlength,imin] = min(cellfun('length',PropList(imatch)));
   Property = PropList{imatch(imin)};
   if ~all(strncmpi(Property,PropList(imatch),minlength)),
       snam = '';
       for kl=imatch(:)'
           snam=[snam,PropList{kl},' '];
       end
      error(sprintf(['Ambiguous property name "%s". Supply more characters.',...
              '\nPossible completions: %s'],Name,snam))
   end
   imatch = imatch(imin);
end
