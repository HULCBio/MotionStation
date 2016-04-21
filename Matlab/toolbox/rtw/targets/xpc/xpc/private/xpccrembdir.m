function xpccrembdir(filename, kernel,env)
% XPCCREMBDIR - xPC Target private function

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.7.2.2 $ $Date: 2004/03/04 20:09:57 $

embdir=[filename,'_xpc_emb'];

if ~mkdir(embdir)
  error(['error creating directory ',embdir,' in current directory']);
end

srcDir   = fullfile(xpcroot, 'target\kernel\embedded');
destFile = fullfile(embdir, [filename '.rtb']);

copyfile(fullfile(srcDir, kernel), destFile);
xpcpatch(destFile, env);
xpcpatchsa(destFile, filename);

if ~exist(fullfile(embdir, 'xpcboot.com'), 'file')
  copyfile(fullfile(srcDir, 'xpcboot.com'), embdir);
end

%filename=filename(4:end);

if length(filename)>8
   filename8=[filename(1:6),'~1'];
else
   filename8=filename;
end

fid=fopen([embdir,'\autoexec.bat'],'w');
fprintf(fid,'xpcboot %s.rtb',filename8);
fclose(fid);

fid=fopen('xpcemb.ctr','w');
fclose(fid);

disp(['### xPC Target StandAlone application ', filename, ...
      '.rtb in directory ', embdir, ' created']);
