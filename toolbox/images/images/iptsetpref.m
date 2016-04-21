function varargout = iptsetpref(prefName, value)
%IPTSETPREF Set Image Processing Toolbox preference.
%   IPTSETPREF(PREFNAME,VALUE) sets the Image Processing Toolbox
%   preference specified by the string PREFNAME to VALUE. The
%   setting persists until the end of the current MATLAB session,
%   or until you change the setting. (To make the value persist
%   between sessions, put the command in your startup.m file.)
%
%   Preference names are case insensitive and can be
%   abbreviated.
%
%   The following preference values can be set:
%
%   'ImshowBorder'        'loose' (default) or 'tight'
%
%        If 'ImshowBorder' is 'loose', IMSHOW displays images
%        with a border between the image and the edges of the
%        figure window, thus leaving room for axes labels,
%        titles, etc. If 'ImshowBorder' is 'tight', then IMSHOW
%        adjusts the figure size so that the image entirely fills
%        the figure. (However, there may still be a border if the
%        image is very small, or if there are other objects
%        besides the image and its axes in the figure.)
%
%   'ImshowAxesVisible'   'on' or 'off' (default)
%
%        If 'ImshowAxesVisible' is 'on', IMSHOW displays images
%        with the axes box and tick labels.  If
%        'ImShowAxesVisible' is 'off', IMSHOW displays images
%        without the axes box and tick labels.
%
%   'ImshowTruesize'      'auto' (default) or 'manual'
%
%        If 'ImshowTruesize' is 'manual', IMSHOW does not call
%        TRUESIZE. If 'ImshowTruesize' is 'auto', IMSHOW
%        automatically decides whether to call TRUESIZE. (IMSHOW
%        calls TRUESIZE if there will be no other objects in the
%        resulting figure besides the image and its axes.) You can
%        override this setting for an individual display by
%        specifying the DISPLAY_OPTION argument to IMSHOW, or you
%        can call TRUESIZE manually after displaying the image.
%
%   'TruesizeWarning'     'on' (default) or 'off'
%
%        If 'TruesizeWarning' is 'on', TRUESIZE displays a
%        warning if the image is too large to fit on the
%        screen. If 'TruesizeWarning' is 'off', TRUESIZE does not
%        display the warning. Note that this preference applies
%        even when you call TRUESIZE indirectly, such as through
%        IMSHOW.
%
%   'ImviewInitialMagnification'   100 (default) or 'fit'
%
%       If 'ImviewInitialMagnification' is 100, IMVIEW displays 
%       the image at 100% magnification. If it is set to 'fit', 
%       the entire image is scaled to fit in the IMVIEW window. 
%       You can override this setting for an individual display 
%       by specifying the 'InitialMagnification' parameter to 
%       IMVIEW.
%
%   IPTSETPREF(PREFNAME) displays the valid values for PREFNAME.
%
%   Example
%   -------
%       iptsetpref('ImshowBorder', 'tight')
%
%   See also IMSHOW, IPTGETPREF, TRUESIZE.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.17.4.4 $  $Date: 2003/08/23 05:52:51 $

error(nargchk(1,2,nargin,'struct'));

if (~ischar(prefName))
    eid = sprintf('Images:%s:invalidPropertyName',mfilename);
    msg = 'First input argument must be a property name string';
    error(eid,'%s',msg);
end

% Get factory IPT preference settings.
factoryPrefs = iptprefs;  
allNames = factoryPrefs(:,1);

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
    msg = sprintf('Ambiguous Image Processing Toolbox preference "%s".', ...
                  prefName);
    error(eid,'%s',msg);
else
    preference = allNames{matchIdx};
end

allowedValues = factoryPrefs{matchIdx, 2};

if (nargin == 1)
    if (nargout == 0)
        % Print possible settings
        defaultValue = factoryPrefs{matchIdx, 3};
        if (isempty(allowedValues))
            fprintf('The Image Processing Toolbox preference setting\n');
            fprintf('"%s" does not have a fixed set of values.\n', preference);
        else
            fprintf('[');
            for k = 1:length(allowedValues)
                thisValue = allowedValues{k};
                isDefault = ~isempty(defaultValue) & ...
                        isequal(defaultValue{1}, thisValue);
                if (isDefault)
                    fprintf(' {%s} ', num2str(thisValue));
                else
                    fprintf(' %s ', num2str(thisValue));
                end
                notLast = k ~= length(allowedValues);
                if (notLast)
                    fprintf('|');
                end
            end
            fprintf(']\n');
        end
        
    else
        % Return possible values as cell array.
        varargout{1} = factoryPrefs{matchIdx,2};
    end
    
else
    % Syntax: IPTSETPREF(PREFNAME,VALUE)
    
    valueIsAcceptable = 0;
    for k = 1:length(allowedValues)
        if (isequal(value, allowedValues{k}))
            valueIsAcceptable = 1;
            registry = iptregistry;
            registry.(preference) = value;
            iptregistry(registry);
            break;
        end
    end
    
    if (~valueIsAcceptable)
        eid = sprintf('Images:%s:invalidPreferenceValue',mfilename);
        msg1 = 'Unacceptable value for Image Processing Toolbox preference ';
        msg2 = sprintf('"%s".', preference);
        error(eid,'%s%s',msg1,msg2);
    end
        
end
