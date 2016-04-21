function varargout=uisetpref(varargin)
%UISETPREF manages preferences used in UIGETPREF
%UISETPREF('addpref',GROUP,NAME,{VAL1,VAL2,VAL3,...})
%    registers the preference with the uisetpref database
%UISETPREF('clearall')
%    resets all registered preferences to 'ask' mode

%  Copyright 1999-2002 The MathWorks, Inc.
%  $Revision: 1.4 $

[varargout{1:max(nargout,1)}]=feval(varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%
function added=addpref(pGroup,pName,enumValues)
%Registers a preference 

allPrefs=getpref('hg','uigetprefprefs','');

[prefString,preamble,options] = locEncodePref(pGroup,pName,enumValues);
added=logical(1);

preambleLoc = findstr(allPrefs,preamble);
if isempty(preambleLoc)
    %we need to add to the database
    allPrefs=[allPrefs,prefString];
    setpref('hg','uigetprefprefs',allPrefs);
elseif isempty(findstr(allPrefs,prefString))
    %this preference is registered with a different set of options.
    %replace it with the new options.  Probably a rare occasion.
    pLoc=findstr(allPrefs,preamble);
    rtLoc=findstr(allPrefs,'>');
    rtLoc=rtLoc(rtLoc>pLoc(1));
    rtLoc=rtLoc(1);
    allPrefs=[allPrefs(1:pLoc-1), prefString, allPrefs(rtLoc+1:end)];
    setpref('hg','uigetprefprefs',allPrefs);
else    
    %preference is already registered with its current set of options
    added=logical(0);
end

%%%%%%%%%
function p=clearall(p)
%Resets all registered preferences to 'ask' mode

if nargin<1
    p=locUnencodeAll;
end

for i=1:length(p)
    setpref(p(i).group,p(i).name,'ask');
    p(i).value='ask';
end

%%%%%%%%%
function [encodedPref,preamble,options]=locEncodePref(pGroup,pName,enumValues)
%Converts a single preference entry into the form <group|name|opt1|opt2>

options='';
for i=1:length(enumValues)
    options=[options,enumValues{i},'|'];
end
options=options(1:end-1); %remove trailing pipe

preamble=strcat('<',pGroup,'|',pName);
encodedPref=strcat(preamble,'|',options,'>');

%%%%%%%%%%
function p=locUnencodePref(s)
%Converts a single preference entry of the form <group|name|opt1|opt2> into
%a structure with fields 'group','name','values', and 'value'

p=struct('group','','name','','values',{{}},'value','');

s=strrep(s,'>','|');
pipeLoc=findstr(s,'|');
p.group=s(2:pipeLoc(1)-1);
p.name=s(pipeLoc(1)+1:pipeLoc(2)-1);
options={};
for i=2:length(pipeLoc)-1
	options{i-1}=s(pipeLoc(i)+1:pipeLoc(i+1)-1);
end
p.values=options;

p.value=getpref(p.group,p.name,'ask');


%%%%%%%%%%%
function p=locUnencodeAll(s)
%Converts many preference entries of the form <group|name|opt1|opt2> into
%a structure vector with fields 'group','name','values', and 'value'

if nargin<1
    s=getpref('hg','uigetprefprefs','');
end

p=struct('group',{},'name',{},'values',{},'value',{});

ltLoc=findstr(s,'<');
rtLoc=findstr(s,'>');

for i=length(ltLoc):-1:1
    p(i)=locUnencodePref(s(ltLoc(i):rtLoc(i)));
end
