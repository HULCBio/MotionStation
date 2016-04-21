function releaseVersion = release_version
%RELEASE_VERSION - Return a version string of the form 11.0, 12.0, etc.
%
%  The release version is parsed by looking at the output of the version
%  string. This function is expecting either:
%    M.m.P.B. (R#.P)
%  or
%    M.m.P.B (R#)
%  where M = major release num, m = minor release num, P = patch num, B =
%  build num.
%
%  In R12, the release numbers started looking like
%
%    6.0.0.69876 Release 12 (Pre-release)
%

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/10 17:53:21 $

  v = version;
  releaseIdx = findstr(v,'(R');

  if length(releaseIdx) == 1
    % Version string will be of form  6.0.0.1234 (R12) Beta 4
    [rlVer,count] = sscanf(v(releaseIdx:end),'(R%d.%d)');
    if count == 2
      releaseVersion = sprintf('%d.%d',rlVer(1),rlVer(2));
      return;
    elseif count == 1
      % someone didn't put the point release on the matlab version #
      [mlVer,count]=sscanf(v,'%d.%d.%d.%d');
      if count == 4
	releaseVersion = sprintf('%d.%d',rlVer(1),mlVer(3));
	return;
      end
    end
  end

  % Look for R12 style version strings

  releaseIdx = findstr(v,'Release ');
  if length(releaseIdx) == 1
    [rlVer, count] = sscanf(v(releaseIdx:end),'Release %d.%d');
    if count == 2
      releaseVersion = sprintf('%d.%d',rlVer(1),rlVer(2));
      return;
    elseif count == 1
      % someone didn't put the point release on the matlab version #
      [mlVer,count]=sscanf(v,'%d.%d.%d.%d');
      if count == 4
	releaseVersion = sprintf('%d.%d',rlVer(1),mlVer(3));
	return;
      end
    end
  end

  error(['unexpected version string']);

%endfunction release_version
