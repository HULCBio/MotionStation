function s = make_ecoder_hook(hook, h, cs)
% MAKE_ECODER_HOOK: Real-Time Workshop Embedded Coder has additional
% hooks (calbacks) to the normal Real-Time Workshop build process.
%

% Copyright 1994-2004 The MathWorks, Inc.
% $Revision: 1.5.2.6 $

% For model reference sim target, do not process the hooks
if strcmp(h.MdlRefBuildArgs.ModelReferenceTargetType, 'SIM')
  return
end

mptEnabled = ec_mpt_enabled(h.ModelName);

switch hook
    case 'entry'
        if mptEnabled
            mpt_ecoder_hook(hook,h.ModelName);
        end

    case 'before_tlc'

        try
            LocalExpandCodeTemplates(h,cs);
            LocalCopyCustomTemplates(h,cs);
        catch
            error(lasterr);
        end

        if mptEnabled
            mpt_ecoder_hook(hook,h.ModelName);
        end

    case 'after_tlc'

        if mptEnabled
            mpt_ecoder_hook(hook,h.ModelName);
        end

    case 'before_make'

        if mptEnabled
            mpt_ecoder_hook(hook,h.ModelName);
        end

    case 'after_make'

        if mptEnabled
            mpt_ecoder_hook(hook,h.ModelName);
        end

    case 'exit'

        if mptEnabled
            mpt_ecoder_hook(hook,h.ModelName);
        end

    otherwise

        if mptEnabled
            mpt_ecoder_hook(hook,h.ModelName);
        end

end


% Expand ERT code templates if they exist
function LocalExpandCodeTemplates(h,cs)
usList{1} = strtok(get_param(cs,'ERTDataHdrFileTemplate'));
usList{2} = strtok(get_param(cs,'ERTDataSrcFileTemplate'));
usList{3} = strtok(get_param(cs,'ERTHdrFileBannerTemplate'));
usList{4} = strtok(get_param(cs,'ERTSrcFileBannerTemplate'));

% Sort list and remove duplicates
sList = sort(usList);
list{1} = sList{1};
idx = 1;

for i = 2 : length(sList)
    cgtName = sList{i};
    if ~isequal(cgtName,list{idx})
        idx = idx + 1;
        list{idx} = cgtName;
    end
end

try,

    for i = 1 : length(list)
      cgtName = list{i};
      
      % Delete the file in the tlc directory to ensure the latest template.
      tlcName = rtw_cgt_name_conv(cgtName,'cgt2tlc');
      outfile = fullfile(h.BuildDirectory,h.GeneratedTLCSubDir,tlcName);
      if exist(outfile,'file')
        rtw_delete_file(outfile);
      end
    
      cgtName = which(cgtName);
      
      if ~isempty(cgtName)
        [dirstr,fname,ext] = fileparts(cgtName);
        if isequal(ext,'.cgt')
          rtw_expand_template(cgtName,outfile);
        else
          rtw_copy_file(cgtName,outfile);
        end
      end
    end

catch
    error(lasterr);
end

% Copy ERT custom template if it exist
function LocalCopyCustomTemplates(h,cs)
try
    templateFile = strtok(get_param(cs,'ERTCustomFileTemplate'));

    % Delete the file in the tlc directory if it exists (to ensure
    % we get the latest template).
    [dirstr,fname,ext] = fileparts(templateFile);
    outfile = fullfile(h.BuildDirectory,h.GeneratedTLCSubDir,[fname,ext]);
    if exist(outfile,'file')
        rtw_delete_file(outfile);
    end

    templateFile = which(templateFile);

    % Copy it to the tlc directory if found
    if ~isempty(templateFile)
        rtw_copy_file(templateFile,outfile);
    end
catch
    error(lasterr);
end
