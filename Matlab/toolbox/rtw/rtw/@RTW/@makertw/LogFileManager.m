function  result = LogFileManager(h,method,str)
%   LOGFILEMANAGER - manage log file for build process
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/15 00:23:56 $

result = '';
if(nargin<3)
   str = '';
end
switch(lower(method))
   case 'create'
      h.LogFileName = fullfile(h.BuildDirectory,'rtwbuildlog.txt');
      fp = fopen(h.LogFileName,'w');
      fclose(fp);
   case 'add'
      if(nargin>=3)
         fp = fopen(h.LogFileName,'a');
         fprintf(fp,'%s\n',str);
         fclose(fp);
      end
   case 'get'
      if(isempty(h.LogFileName))
         result = '';
         return;
      end
      fp = fopen(h.LogFileName,'rt');
      if(fp<=2)
         result = '';
         return;
      end;
      result = fread(fp, '*char')';
      fclose(fp);
   case 'flush'
      result = LogFileManager(h,'get');
      if(isempty(result))
         return;
      end
      logTxt = result;
      
      nag             = slsfnagctlr('NagTemplate');
      nag.type = 'Log';
      nag.msg.details = logTxt;
      nag.msg.type    = 'Build';
      nag.msg.summary = '';
      nag.component   = 'RTW Builder';
      nag.sourceName   = h.ModelName;
      nag.ids         = [];
      nag.blkHandles  = [];
      
      nag.refDir = h.BuildDirectory;
      
      slsfnagctlr('Naglog', 'push', nag);
      slsfnagctlr('View');
end



