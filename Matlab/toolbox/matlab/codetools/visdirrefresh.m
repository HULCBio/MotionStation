function visdirrefresh(inStr)
%VISDIRREFRESH  Refresh HTML directory reports.
%   VISDIRREFRESH is initiated by a POST method inside a <FORM> tag in the
%   various directory reports.
%
%   See also VISDIR, STANDARDRPT.

% Copyright 1984-2003 The MathWorks, Inc.

strc = parsehtmlpostmethod(inStr);

% Use try-catch to avoid leaving up misleading HTML
try

    if strcmp(strc.reporttype,'standardrpt')
        com.mathworks.mde.filebrowser.FileBrowser.refresh;
    else
        if isfield(strc,'option')
            feval(strc.reporttype,strc.name,strc.option);
        elseif isfield(strc,'name')
            feval(strc.reporttype,strc.name);
        else
            feval(strc.reporttype);
        end
    end

catch

    errMsg = sprintf('<html><body><span style="color:#F00">Error generating report.<p/>%s\n</span></body></html>', ...
        lasterr);
    web(['text://' errMsg],'-noaddressbox')

end

