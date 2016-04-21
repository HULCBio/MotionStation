function errMsg = rtw_expand_template_from_tlc(name, modelName)
% Expand the specifed ERT code generation template.
%
% Args:
%   name - name of the code geneartion template to expand
%
% Returns:
%   'success'        - success
%   'file not found' - failure (could not find file on MATLAB path)
%   lasterr          - failure (error during template expansion)

% Copyright 1994-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $

  cgt = which(name);
  
  if ~isempty(cgt)
    [dirstr,fname,ext] = fileparts(cgt);
    try
      h = get_param(modelName, 'MakeRTWSettingsObject');
      if isempty(h)
        error(['Unable to load object handle for the makertw class for model: ''',...
                  modelName,'''']);
      end
  
      if isequal(ext,'.cgt')
        tlcName = rtw_cgt_name_conv([fname,ext],'cgt2tlc');
        outfile = fullfile(h.BuildDirectory,h.GeneratedTLCSubDir,tlcName);
        rtw_expand_template(cgt,outfile);
      else
        outfile = fullfile(h.BuildDirectory,h.GeneratedTLCSubDir,[fname,ext]);
        rtw_copy_file(cgt,outfile);
      end
      errMsg = 'success';
    catch
      errMsg = lasterr;
    end
  else
    errMsg = 'file not found';
  end
