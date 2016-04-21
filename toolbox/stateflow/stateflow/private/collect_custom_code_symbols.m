function symbols = collect_custom_code_symbols( targetId, customCode, symbols)

customCode = expand_double_byte_string(customCode);

% must get these before we cd()

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.4.2.2 $  $Date: 2004/04/15 00:56:22 $
makeInfo = sfc('makeinfo',targetId,targetId);
userIncludes = makeInfo.fileNameInfo.userIncludeDirs;

% create a temporary file in the info dir that mimics the top of the .h file that
% includes the custom code
savdir = pwd;
infoDir = get_info_dir_path(targetId);
cd(infoDir);
name = 'custom_code_included';
cname = [name '.c'];
xrefname = [name '.xrf'];
objname = [name '.obj'];

%disp(['creating ' cname]);
fid = fopen( cname, 'wt' );

if (fid<3),
   throw_custom_code_error(sprintf('Error while parsing custom code.(#%d)\nFailed to create temporary file %s.',targetId,cname));
end

fprintf( fid, '%s\n','#define CALL_EVENT 999999');
fprintf( fid, '%s\n','extern unsigned int _sfEvent_;');
fprintf( fid, '#line 1 "in target ''%s'' (#%d) custom code, line"\n',sf('get',targetId,'.name'),targetId );
fprintf( fid, '%s', customCode );
fprintf( fid, '\n' );
fclose(fid);

mRoot = sf_get_component_root('matlab');
lccRoot = sf_get_component_root('lcc');

includeDirs = { ...
	 [lccRoot,'\include'] ...
	,[mRoot,'\extern\include'] ...
	,[mRoot,'\simulink\include'] ...
	,userIncludes{:} ...
};

if isempty(includeDirs)
	includeDirString = '';
else
	includeDirString = sprintf(' -I"%s"',includeDirs{:});
end

cmd = [lccRoot '\bin\lcc.exe -x' xrefname ' -c ' cname ' -Zp8 -noregistrylookup -DMATLAB_MEX_FILE '...
      includeDirString ];

cd(savdir);
safely_execute_dos_command(infoDir,cmd);

cd(infoDir);
%disp(['symbols in ' xrefname]);
if ~exist(objname,'file')
   cleanup_files(cname,objname,xrefname);
   cd(savdir);
   throw_custom_code_error(sprintf('Error while parsing custom code.(#%d)',targetId));
end

symbols = parse_xref_file(xrefname,symbols);
cleanup_files(cname,objname,xrefname);
cd(savdir);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cleanup_files(cname,objname,xrefname)
if exist(cname,'file')
   sf_delete_file(cname);
end
if exist(objname,'file')
   sf_delete_file(objname);
end
if exist(xrefname,'file')
   sf_delete_file(xrefname);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function symbols = parse_xref_file(name,symbols)
%tic;
a = read_and_tokenize_file(name);
%toc;
% the symbols we are interested in:
% 
%tic;
skip = 0; % skip lines of called functions
for i = 1:length(a)
   if ~skip
      switch a{i}{1}
      case { 'x#', 'xf', 'xF', 'xd', 'xD', 'xn' }
         symbols{end+1} = a{i}{2};
      case { 'e', 's' }
         skip = 1; % next line is list of called functions
      otherwise
         ;
      end
   end
   skip = 0;
end
%toc;
%disp(symbols)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read in a text file and break it into a 
% cell array of cell arrays, split on whitespace
function a = read_and_tokenize_file(name)
a = {};
fid = fopen(name, 'rt');
line = fgetl(fid);
while ~isequal(line,-1)
   fields = sf('SplitStringIntoCells',line);
   if ~isempty(fields)
      a{end+1} = fields;
   end
   line = fgetl(fid);
end

fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function path = get_info_dir_path(targetId)

machineId   = sf('get', targetId, '.machine');
machineName = sf('get', machineId, '.name');
targetName  = sf('get', targetId, '.name');
path = create_directory_path(pwd, 'sfprj', 'build', machineName, targetName, 'info');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function throw_custom_code_error(msg),
%
% Throws a parse error with the proper slsf-token.
%
   if nargin > 0 & ~isempty(msg), sf_display('Parse', msg); end;
    
   error(slsfnagctlr('NagToken'));

