function status = print_html_str(str, jobName)

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/04/15 00:59:02 $
  
persistent htmlRenderer;
persistent frame;

status = 0;

try
  if(usejava('jvm') & usejava('awt') & usejava('swing'))
    % proceed
  else
    % no java. dont bother doing anything.
    return;
  end
    if(isempty(htmlRenderer))
        htmlRenderer = com.mathworks.mlwidgets.html.HTMLRenderer;
        frame = java.awt.Frame;
        frame.add(htmlRenderer);
        mlock;
    end

    switch nargin
    case 0
        % print_html_str with no parameters is used to initialize
        % the java widgets that handle html rendering.  These objects
        % are not created until the HTML renderer has a string to process.
        % This is called the first time a truthtable or eml opened. G143204
        htmlRenderer.setHtmlText('');
        return;
    case 1
        jobName = 'MATLAB HTML Print';
    end

    htmlRenderer.setHtmlText(str);
    frame.setTitle(jobName);

    htmlRenderer.doPrint;
catch
    disp(lasterr);
    status = 1;
end






