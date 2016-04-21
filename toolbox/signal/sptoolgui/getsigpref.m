function [valueOutput,errorStr]=getsigpref(propList,defaultList)
%GETSIGPREF Get SPTool preferences.
%   val = GETSIGPREF(prop) extracts and returns the value associated 
%   with the property prop in SPTool. If prop doesn't exist, GETSIGPREF 
%   returns an empty matrix. If prop is a cell array, then the output 
%   val is a cell array of the same size.
%
%   val = GETSIGPREF(prop,default) returns the default value for prop
%   if there is no current value associated with the property in question.
%
%   GETSIGPREF is a structure containing all the property/value pairs for the 
%   preferences in SPTool.  If this structure is empty, there are no 
%   saved preferences.
%
%   See also SETSIGPREF.

%   Ned Gulley, 9-11-95
%   Adapted for Signal, Tom Krauss, 3-22-96
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.9 $ $Date: 2002/04/15 00:04:02 $

global SIGPREFS
% If SIGPREFS has not been loaded yet, its size will be 0-by-0
errorStr = [];

if (size(SIGPREFS,1)==0),
    fileName='sigprefs.mat';
    if isempty(which(fileName))
        % There is no preferences file
        if nargout>1, errorStr='There are no saved preferences'; end
        valueOutput=[];
        SIGPREFS = 0;
        return
    else
        % The file exists, so go ahead and load it
        load(fileName);
    end
elseif ~isstruct(SIGPREFS)
    % we've already looked for sigprefs.mat on disk since the
    % last time globals were cleared (new session or after clear global or
    % something).  So we don't need to look for it on disk again, because
    % if it has been saved to disk then SIGPREFS will be a structure!
    valueOutput = [];
    return     
end

switch nargin
case 0,
    valueOutput=SIGPREFS;

otherwise,    % Need to catch both nargin==1 and nargin==2
    allPropList=fieldnames(SIGPREFS);
 
    if ~iscell(propList),
        % If the input isn't a cell, then it can only be a single string
        prop=propList;
        if isempty(strmatch(prop,allPropList)),
            val=[];
        else
            val=getfield(SIGPREFS,prop);
        end
        if isempty(val) & (nargin>2),
            valueOutput=defaultList;
        else
            valueOutput=val;
        end
    else
        % The input is a cell array; loop through it
        valueOutput=cell(size(propList));
        for count=1:length(propList),
            prop=propList{count};
            if isempty(strmatch(prop,allPropList)),
              % The property in question does not appear in the preferences 
                val=[];
            else
                val=getfield(SIGPREFS,prop);
            end
            if isempty(val) & (nargin>2),
                    valueOutput{count}=defaultList{count};
            else
                valueOutput{count}=val;
            end
        end
    end

end

