function target_asap2_utils(action, modelName, varargin)
% TARGET_ASAP2_UTILS    Utilities to help each target perform ASAP2 post
% processing

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $
switch (lower(action))
    case 'postprocess'
        i_postProcess(modelName, varargin{:});
    otherwise
        error('Unknown action');
end;

% returns the mapfile and asap2file for the given modelName
function varargout = i_getFilenames(modelName)
    % MAP file is in the model dir
    mapfile = dir(['../' modelName '.map']);
    % ASAP2 file is in the build dir
    asap2file = dir([modelName '.a2l']);

    varargout = { asap2file, mapfile };
    if nargout > 0 
        varargout = {varargout{1:nargout}};
    else
        varargout = {};
    end
return;

% removes ASAP2 files / MAP files if they should not be present
% propagates MAP file addresses into the ASAP2 file if appropriate
function i_postProcess(modelName, perlFile, mapfile)


   if nargin == 2
       [asap2file, mapfile] = i_getFilenames(modelName);
   else
       asap2file = i_getFilenames(modelName);
       mapfile = dir(mapfile);
   end

   
   % check the RTWOptions to see if we generated an ASAP2 file
   optAsap2 = uget_param(modelName,'GenerateASAP2');
   if (strcmp(optAsap2,'off'))
       % ASAP2 option not checked delete the ASAP2 file as it may be out of date 
       if (~isempty(asap2file)) 
           delete(asap2file.name); 
       end;
       return; 
   end;
   
   generateCodeOnly = strcmp(get_param(modelName,'RTWGenerateCodeOnly'),'on');
   % remove any MAP file if we are only generating code
   if (generateCodeOnly)
       if (~isempty(mapfile))
           % Workaround for dir issue on JNT
           if strcmp(mapfile.name,['..' filesep modelName '.map'])
               mapfile.name = [modelName '.map'];
           end
           delete(['../' mapfile.name]);
       end;
   end;
   
   if ( strcmp(optAsap2,'on') & ~generateCodeOnly)
       % should be able to post process an ASAP2 file
       if (~isempty(asap2file) & ~isempty(mapfile))
           % Workaround for dir issue on JNT
           if strcmp(mapfile.name,['..' filesep modelName '.map'])
               mapfile.name = [modelName '.map'];
           end
           % post process
           % run the asap2 post processing script
           asap2post_targets([asap2file.name],['../' mapfile.name],perlFile);
           fprintf(1,'### Found ASAP2 file and MAP file.   Propagated addresses from MAP file into ASAP2 file\n');     
       else
           % something has gone wrong
           fprintf(1,'### Error during propagation of addresses from the MAP file into the ASAP2 file\n');  
       end;
   end;
return;
