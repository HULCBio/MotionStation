function filepath = get_filepath_from_user(name, title),
%GET_FILEPATH_FROM_USER(NAME, TITLE)
%   FILEPATH = GET_FILEPATH_FROM_USER(NAME, TITLE)
%

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2004/04/15 00:58:02 $
%
%
    [file, dir] = uiputfile(name, title);
    filepath = [dir filesep file];

