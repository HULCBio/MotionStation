function webmenufcn(webmenu, cmd)
%WEBMENUFCN Implements the figure web menu.
%  WEBMENUFCN(CMD) invokes web menu command CMD on figure GCBF.
%  WEBMENUFCN(H, CMD) invokes insert menu command CMD on figure H.
%
%  CMD can be one of the following:
%
%    
%   MathWorksHome
%   Products
%   Membership
%   TechSupport
%
%   MATLABCentral
%   FileExchange
%   NewsgroupAccess
%   Newsletters
%
%   StudentRegistration
%   WebStore
%
%   CheckUpdates

%  CMD Values For Internal Use Only:
%    WebmenuPost

%  Copyright 1984-2002 The MathWorks, Inc. 

error(nargchk(1,2,nargin))

if ischar(webmenu)
    cmd = webmenu;
    webmenu = gcbo;
    hfig = gcbf;
end

switch lower(cmd)
    case 'webmenupost'
        % FOR INTERNAL USE.
        if ~isstudent
            if ~isempty(gcbo)
                set(findobj(allchild(gcbo),'tag','figMenuWebStudent'), ...
                    'visible','off');
                set(findobj(allchild(gcbo),'tag','figMenuWebStore'), ...
                    'visible','off');
            end   
        else
            if ~isempty(gcbo)
                set(findobj(allchild(gcbo),'tag','figMenuWebMembership'), ...
                    'visible','off');                
            end             
        end
    case 'mathworkshome'
        web http://www.mathworks.com -browser;
    case 'products'
        web http://www.mathworks.com/products -browser;
    case 'membership'
        web http://www.mathworks.com/membership -browser;
    case 'techsupport'
        web http://www.mathworks.com/support -browser;
    case 'matlabcentral'
        web http://www.mathworks.com/matlabcentral_redirect -browser;
    case 'fileexchange'
        web http://www.mathworks.com/fileexchange_redirect -browser;
    case 'newsgroupaccess'
        web http://www.mathworks.com/newsreader_redirect -browser;
    case 'newsletters'
        web http://www.mathworks.com/company/newsletters -browser;
    case 'studentregistration'
        web http://www.mathworks.com/products/studentversion/register.shtml -browser;
    case 'webstore'
        web http://www.mathworks.com/svstore -browser;
    case 'checkupdates'
        com.mathworks.mde.updates.UpdateCheck.invoke(com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame);
end
