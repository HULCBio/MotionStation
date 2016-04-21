function xpctarget_make_rtw_hook(makeRTWHookMethod, modelName, rtwroot,templateMakefile,  buildOpts, buildArgs)

% XPCTARGET_MAKE_RTW_HOOK - xPC Target specific hook file for the build process (make_rtw).

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.15.2.2 $ $Date: 2004/03/30 13:14:48 $
standalone=0;
switch makeRTWHookMethod
 case 'entry'
  fprintf(1,'\n### Starting xPC Target build procedure for model: %s\n', ...
          modelName);
  clear([modelName 'pt'], [modelName 'bio']);

 case 'before_tlc'

 case 'before_make'
  if ~isModelRef(modelName);
    [bio, bioNames] = patchbiopt(['..\',modelName]);
    patchscblocks(modelName, bio, bioNames);
  end
    CANLib = getxpcenv('CANLibrary');
    fid = fopen('xpcextralibs.mk', 'w');
    if fid < 0
      error('Could not open xpcextralibs.mk');
    end
    if strcmp(CANLib,'200 ISA')
      fprintf(fid,'CANAC2_C200= \r\n');
    elseif strcmp(CANLib,'527 ISA')
      fprintf(fid,'CANAC2_527= \r\n');
    elseif strcmp(CANLib,'1000 PCI')
      fprintf(fid,'CANAC2_1000= \r\n');
    elseif strcmp(CANLib,'1000 MB PCI')
      fprintf(fid,'CANAC2_1000_MB= \r\n');
    elseif strcmp(CANLib,'PC104')
      fprintf(fid,'CANAC2_104= \r\n');
    end
    fclose(fid);

 case 'exit'

  if ~isModelRef(modelName);
    if ~buildOpts.generateCodeOnly
      if ~exist('..\xpcnoload.ctr','file')
        %     if ~exist('xpcemb.ctr','file')
        tmp        = xpcoptions;
        tgobgname  = tmp.objname;
        xpcobj     = tmp.xpcObjCom;
        currentDir = pwd;
        if (xpcobj)
          if ~isempty(ver('embedded'))
            xpcgencom(modelName);
          else %embedded option not installed
            xpcgencomwarn(modelName);
          end
        end    % if (xpcobj)
        cd('..');
        standalone=xpcload(modelName);
        if(~standalone)
          fprintf(2,'\n### create xPC Object %s\n', tgobgname);
          fprintf(2,'### Download Model onto Target\n');
          tg = xpc
          cd(currentDir);
          eval(['assignin(''base'',  ''',tgobgname,''', tg)']);
        end
      end % if ~exist('xpcnoload.ctr','file'
    end % if ~buildOpts.generateCodeOnly
  end

  fprintf(1,'### Successful completion of xPC Target build procedure for model: %s\n', modelName);
  xpcpollwarn(modelName);
end

function yn = isModelRef(mdl)
yn = strcmpi(get_param(mdl, 'ModelReferenceTargetType'), 'RTW');