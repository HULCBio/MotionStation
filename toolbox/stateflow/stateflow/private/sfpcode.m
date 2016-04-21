function sfpcode( command )
% SFPCODE or SFPCODE('update')
%    pcodes all Stateflow M files in the following directories
%       toolbox/stateflow/stateflow
%       toolbox/stateflow/stateflow/private
%       toolbox/stateflow/coder
%       toolbox/stateflow/coder/private
%       toolbox/stateflow/sfdemos
%
%    This function first deletes all P files that are older with
%    respect to their corresponding M file. It then generates pcode
%    for all M files without pcode. Contents.m files are skipped.
%
% SFPCODE('delete')
%    deletes all pcode files in above mentioned Stateflow
%    directories
%
% SFPCODE('refresh')
%    deletes all pcode files in above mentioned Stateflow
%    directories and then regenerates them again. Contents.m files
%    are skipped.

% E. Mehran Mestchian
% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.7.2.1 $  $Date: 2004/04/15 01:00:11 $

if nargin==0, command='update'; end

root = matlabroot;
if ispc
   writable = 'attrib -r *.p';
   readonly = 'attrib +r *.p';
else
   writable = 'chmod +w *.p';
   readonly = 'chmod -w *.p';
end

pcode_dir(command,root,'toolbox/stateflow/stateflow',writable,readonly);
pcode_dir(command,root,'toolbox/stateflow/stateflow/private',writable,readonly);
pcode_dir(command,root,'toolbox/stateflow/coder',writable,readonly);
pcode_dir(command,root,'toolbox/stateflow/coder/private',writable,readonly);
pcode_dir(command,root,'toolbox/stateflow/sfdemos',writable,readonly);

% Stateflow toolbox changed => rehash
v = version;
try
   if v(1)=='5' % MATLAB 5.x.x
      feature('rehash','toolboxreset');
   else % MATLAB 6 or higher
      rehash('toolboxreset');
   end
catch
   disp(lasterr);
end


function pcode_dir( command, root, directory, writable, readonly, doDisplay )
    
    directory = fullfile(root,directory);
    initialDir = pwd;
    cd(directory);
    
    if nargin<6, doDisplay=1; end
    
    try      
        mFiles = dir('*.m');
        noMfiles = size(mFiles,1);
        if noMfiles==0, return; end
        
        pFiles = dir('*.p');
        noPfiles = size(pFiles,1);
        
        switch command
        case 'update'
            if doDisplay
                disp(['updating pfiles in ---> ',pwd])
            end
            if (noPfiles>0), dos(writable,'-echo'); end
            % prune all invalid or older p files
            for i=1:noPfiles
                pF = pFiles(i);
                mF = dir([pF.name(1:end-1),'m']);
                if isempty(mF) ...
                   | (sf_date_num(mF.date)>sf_date_num(pF.date)) ...
                   | isequal(pF.name,'Contents.p') ...
                   | isequal(pF.name,'sfpcode.p')
                   
                   delete(pF.name);
                   disp(['  delete ',pF.name]);
                end
            end
            % pcode all M files without corresponding P file
            % however, skip Contents.m and sfpcode.m files
            for i=1:noMfiles
                mF = mFiles(i);
                mF.pName = [mF.name(1:end-1),'p'];
                pF = dir(mF.pName);
                if isempty(pF) ...
                 & (~isequal(mF.name,'Contents.m')) ...
                 & (~isequal(mF.name,'sfpcode.m'))
                    try
                        pcode(mF.name,'-inplace');
                        if(exist(mF.pName,'file'))
                           disp(['   pcode ',mF.name]);
                        else
                           error('pcoding failed');
                        end
                    catch
                        disp(lasterr);
                        disp(['FAILED to pcode ',mF.name,' -- ignored']);
                        lasterr('');
                    end
                end
            end
            dos(readonly,'-echo');
        case 'delete'
            if doDisplay
                disp(['deleting pfile in ---> ',pwd])
            end
            if (noPfiles>0), dos(writable,'-echo'); end
            delete('*.p');
        case 'refresh'
            if doDisplay
                disp(['refreshing pfiles in ---> ',pwd])
            end
            pcode_dir('delete','',directory,writable,readonly,0);
            pcode_dir('update','',directory,writable,readonly,0);
        otherwise, warning('bad pcode_dir command!');
        end   
    catch
        disp(lasterr);
    end
    cd(initialDir);   
