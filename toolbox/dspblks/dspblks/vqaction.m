function aClose = vqaction(ud)
%ACTION Perform the action of the export dialog

%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:17:48 $

%   ud.exportTOpopup = 1;%1/2/3
%   ud.outputVarName = {'finalCB','Err', 'Entropy'};
%   ud.exportOverwrite = 0; 
target = ud.exportTOpopup;
% Call out to the specific function depending on the exporttarget
switch target,
    case 1,  aClose = export2wkspace(ud);%'Workspace'
    case 2,  aClose = export2file(ud, 'text');%'Text-file'
    case 3,  aClose = export2file(ud, 'mat');%'MAT-file'
end


%---------------------------------------------------------------------
function aClose = export2wkspace(ud)
%EXPORT2WKSPACE Export Coefficients to the MATLAB Workspace.  
%
% Inputs:
%    ud - UserData

variables = {ud.finalCodebook ud.errorArray ud.entropyArray};
tnames    = ud.outputVarName;%get(hXP,'TargetNames');

% Check if the variables exist in the workspace.
[varsExist, existMsg] = chkIfVarExistInWksp(tnames);

overwriteVars = ud.exportOverwrite; 

if ~overwriteVars & varsExist,
    % Variables exist, put up a warning dialog/send message and set the
    % flag to not close the dialog.
    % warndlg(existMsg);
    set(ud.hTextStatus,'ForeGroundColor','Red');  set(ud.hTextStatus,'String',existMsg);
    
    aClose = 0;
else
    for i = 1:length(tnames)%length(tnames)=3
        
        % Check for valid names
        if isvarname(tnames{i}),
            assign2wkspace('base',tnames{i},variables{i});
        else
            errordlg([tnames{i} ' is not a valid variable name.']);
        end
    end
    
    % Message to be displayed in the command window. 
    exportMsg = 'Export Dialog: Variables have been exported to the workspace.';
    set(ud.hTextStatus,'ForeGroundColor','Black');  set(ud.hTextStatus,'String',exportMsg);
    
    aClose = 1;
end

%---------------------------------------------------------------------
function aClose = export2file(ud, fileType)
%EXPORT2FILE Export filter coefficients to a file (MAT or Text).
%
variables = {ud.finalCodebook ud.errorArray ud.entropyArray};
tnames    = ud.outputVarName;

switch fileType,
    case 'text',
        file = 'untitled.txt';
        dlgStr = 'Export Filter Coefficients to a Text-file';
        ext = 'txt';
    case 'mat',
        file = 'untitled.mat';
        dlgStr = 'Export Filter Coefficients to a MAT-file';
        ext = 'mat';
end

% Put up the file selection dialog
[filename, pathname] = uiputfile(file,dlgStr);
file = [pathname filename];

% filename is 0 if "Cancel" was clicked.
if filename ~= 0,
    aClose = 1;
    % Unix returns a path that sometimes includes two paths (the
    % current path followed by the path to the file) seperated by '//'.
    % Remove the first path.
    indx = findstr(file,[filesep,filesep]);
    if ~isempty(indx)
        file = file(indx+1:end);
    end
    
    if strcmpi(fileType,'mat'),
        save2matfile(ud,file);
    else            
        save2textfile(ud,file);
    end
else
    aClose = 0;
end

%------------------------------------------------------------------------
function save2matfile(ud,f_i_l_e)
%SAVE2MATFILE Save filter coefficients to a MAT-file
%
% Inputs:
%   f_i_l_e - String containing the MAT-file name.
%   ud - User Data

variables = {ud.finalCodebook ud.errorArray ud.entropyArray};
tnames    = ud.outputVarName;

for i = 1:length(tnames)
    if isvarname(tnames{i}),
        assign2wkspace('caller',tnames{i},variables{i});
    else
        error([tnames{i} ' is not a valid variable name.']);
    end
end

% Create the MAT-file
save(f_i_l_e,tnames{:},'-mat');

%------------------------------------------------------------------------
function save2textfile(ud, file)
%SAVE2TEXTFILE Save filter coefficients to a Text-file
%
% Inputs:
%   file  - String containing the Text-file name.
%   ud - User Data

fid = fopen(file, 'w');
savevars2textfile(ud, fid);

fclose(fid);
% Launch the MATLAB editor (to display the coefficients)
edit(file);

%------------------------------------------------------------------------
function savevars2textfile(ud, fid)

variables = {ud.finalCodebook ud.errorArray ud.entropyArray};
labels    = {['Final Codebook'] ['Error'] ['Entropy']};

for i = 1:length(labels);
    fprintf(fid, '%s:\n', labels{i});
    fprintf(fid, '\t%f\n', variables{i});
end

%-------------------------------------------------------------------
function assign2wkspace(wkspace, name, variable)

assignin(wkspace, name, variable);

%-------------------------------------------------------------------
function [varsExist, existMsg] = chkIfVarExistInWksp(vnames);
% CHKIFVAREXISTINWKSP Check if the variables exist in the workspace.
%
% Input:
%   vnames - Filter Structure specific coefficient strings stored
%               in FDATool's UserData.
%
% Ouptuts:
%   varsExist - Boolean flag to indicate if variables exist in the
%               MATLAB workspace.
%   existMsg  - Warning dialog string to let the user know that their
%               variable(s) already exists.             

varsExist = 0;
existMsg = '';

for n = 1:length(vnames),
    % Using the evaluatevars function since the "exist" function cannot be made
    % to look in the base MATLAB workspace.  
    [vals, errStr] = evaluatevars(vnames{n}); 
    
    % Put up a message if the variables exist
    if ~isempty(vals),
        varsExist = 1;
        existMsg = ['Export Dialog: The variable ' vnames{n} ' already exists in the MATLAB workspace.'];
        return; % Return immediately after finding the first existing variable
    end
end

% [EOF]
