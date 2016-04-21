function value = iptgetpref(prefName)
%IPTGETPREF Get Image Processing Toolbox preference.
%   PREFS = IPTGETPREF without an input argument returns a structure
%   containing all the Image Processing Toolbox preferences with their
%   current values.  Each field in the structure has the name of an Image
%   Processing Toolbox preference.  See IPTSETPREF for a list.
%
%   VALUE = IPTGETPREF(PREFNAME) returns the value of the Image
%   Processing Toolbox preference specified by the string PREFNAME.  See
%   IPTSETPREF for a complete list of valid preference names.  Preference
%   names are not case-sensitive and can be abbreviated.
%
%   Example
%   -------
%       value = iptgetpref('ImshowAxesVisible')
%
%   See also IMSHOW, IPTSETPREF.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.13.4.3 $  $Date: 2003/08/01 18:09:16 $

checknargin(0,1,nargin,mfilename);

% Get IPT factory preference settings.
factoryPrefs = iptprefs;
allNames = factoryPrefs(:,1);

% What is currently stored in the IPT registry?
registryStruct = iptregistry;
if (isempty(registryStruct))
    registryFieldNames = {};
else
    registryFieldNames = fieldnames(registryStruct);
end

if (nargin == 0)
    % Display all current preference settings.
    value = [];
    for k = 1:length(allNames)
        thisField = allNames{k};
        registryContainsPreference = length(strmatch(thisField, ...
                registryFieldNames, 'exact')) > 0;
        if (registryContainsPreference)
            value.(thisField) = registryStruct.(thisField);
        else
            % Use default value
            value.(thisField) = factoryPrefs{k,3}{1};
        end
    end
    
else
    % Return specified setting.
    if (~isa(prefName, 'char'))
        eid = sprintf('Images:%s:invalidPreferenceName',mfilename);
        msg = 'Preference name must be a string.';
        error(eid,'%s',msg);
    end

    % Convert factory preference names to lower case.
    lowerNames = cell(size(allNames));
    for k = 1:length(lowerNames)
        lowerNames{k} = lower(allNames{k});
    end
    
    matchIdx = strmatch(lower(prefName), lowerNames);
    if (isempty(matchIdx))
        eid = sprintf('Images:%s:unknownPreference',mfilename);
        msg = sprintf('Unknown Image Processing Toolbox preference "%s".', ...
                      prefName);
        error(eid,'%s',msg);
    elseif (length(matchIdx) > 1)
        eid = sprintf('Images:%s:ambiguousPreference',mfilename);
        msg = sprintf('Ambiguous Image Processing Toolbox preference "%s".',...
                      prefName);
        error(eid,'%s',msg);
    else
        preference = allNames{matchIdx};
    end

    registryContainsPreference = length(strmatch(preference, ...
            registryFieldNames, 'exact')) > 0;
    if (registryContainsPreference)
        value = registryStruct.(preference);
    else
        value = factoryPrefs{matchIdx, 3}{1};
    end
end
