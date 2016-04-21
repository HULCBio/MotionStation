function visdirformhandler(inStr)
%VISDIRFORMHANDLER  Manage the preferences for reports with checkboxes.
%   VISDIRFORMHANDLER is invoked by a POST method inside a <FORM> tag in
%   the various directory reports. 
%
%   See also VISDIR, VISDIRREFRESH.

% Copyright 1984-2004 The MathWorks, Inc.

strc = parsehtmlpostmethod(inStr);

% Unfortunately this file needs to know specific information about the
% prefs for each of the report types. This is because only boxes that are
% checked are reported, but we need to report the unchecked boxes too.

% The hidden "reporttype" input is named for the page from which the report
% was requested.
switch strc.reporttype
    case 'dofixrpt'
        interpretCheckbox(strc,'planDisplayMode')
        interpretCheckbox(strc,'todoDisplayMode')
        interpretCheckbox(strc,'fixmeDisplayMode')
        interpretCheckbox(strc,'regexpDisplayMode')
        setpref('dirtools','regexpText',strc.regexpText)

    case 'standardrpt'
        interpretCheckbox(strc,'listByContentsMode')
        interpretCheckbox(strc,'showActionsMode')
        interpretCheckbox(strc,'thumbnailDisplayMode')
        interpretCheckbox(strc,'fileSizeDisplayMode')
        interpretCheckbox(strc,'typeDisplayMode')
        

    case 'helprpt'
        interpretCheckbox(strc,'helpDisplayMode')
        interpretCheckbox(strc,'h1DisplayMode')
        interpretCheckbox(strc,'copyrightDisplayMode')
        interpretCheckbox(strc,'helpSubfunsDisplayMode')
        interpretCheckbox(strc,'seeAlsoDisplayMode')
        interpretCheckbox(strc,'exampleDisplayMode')

    case 'deprpt'
        interpretCheckbox(strc,'depSubfunDisplayMode')
        interpretCheckbox(strc,'localParentDisplayMode')
        interpretCheckbox(strc,'allChildDisplayMode')

end


function interpretCheckbox(strc,modeStr)
% Interpret the setting of the checkbox as needed

thePref = 0;
if isfield(strc,modeStr)
    if strcmpi(strc.(modeStr),'on')
        thePref = 1;
    end
else
    % The field doesn't exist. Turn the preference off.
    thePref = 0;
end

setpref('dirtools',modeStr,thePref)
