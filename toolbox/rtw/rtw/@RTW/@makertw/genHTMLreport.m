function genHTMLreport(h)
%   GENHTMLREPORT - Generate HTML report if neccesary

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2004/04/15 00:23:59 $

rptContentsFile = rtwprivate('rtwattic', 'getContentsFileName');
rptFileName     = rtwprivate('rtwattic', 'getReportFileName');
if ~isempty(rptContentsFile)
  % get submodels htmlrpt links
  infoStruct = rtwprivate('rtwinfomatman',h.StartDirToRestore,'load', ...
                          'binary', h.ModelName, ...
                          h.MdlRefBuildArgs.ModelReferenceTargetType);
  % add links to submodels html report.
  if isfield(infoStruct, 'htmlrptLinks')
    insert_link_to_submodels_htmlrpt(infoStruct.htmlrptLinks, ...
                                     rptContentsFile,infoStruct);
  end
  % save current htmlrpt link into rtwinfomat.
  infoStruct = rtwprivate('rtwinfomatman',h.StartDirToRestore, ...
                          'updatehtmlrptLinks','binary', ...
                          h.ModelName, ...
                          h.MdlRefBuildArgs.ModelReferenceTargetType, ...
                          rptFileName);
  rtwprivate('rtwreport', 'convertC2HTML', rptContentsFile);
  if strcmp(h.MdlRefBuildArgs.ModelReferenceTargetType,'NONE') || ...
        h.MdlRefBuildArgs.UpdateTopModelReferenceTarget   
    if ~strcmp(uget_param(h.ModelName,'LaunchReport'),'off')
        dasRoot = DAStudio.Root;
        if dasRoot.hasWebBrowser            
            rtwprivate('rtwshowhtml', rptFileName, 'UseWebBrowserWidget');
        else
            rtwprivate('rtwshowhtml', rptFileName);
        end
    end
  end
end

function insert_link_to_submodels_htmlrpt(htmlrptLinks,rptContentsFile,infoStruct)
if ~isempty(htmlrptLinks)    
    rptBuffer = fileread(rptContentsFile);
    insertLinks = '<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1" WIDTH="100%" BGCOLOR="#ffffff">';
    insertLinks = [insertLinks '<TR><TD><B>Referenced Models</B></TD></TR>'];
    htmlsubmodel={}; % submodels with html report
    for i=1:length(htmlrptLinks)
        [pathStr submodelName] = fileparts(htmlrptLinks{i});
        submodelName = submodelName(1:end-12); % remove '_codegen_rpt'
        htmlsubmodel = [htmlsubmodel,{submodelName}];
        % html relative link always use '/' on all platforms.
        relativeLink = strrep(fullfile(infoStruct.relativePathToAnchor, '..', htmlrptLinks{i}),'\','/');
        insertLinks = [insertLinks '<TR><TD><A HREF="' relativeLink '" TARGET=_top>' submodelName '</A></TD><TR>'];
    end    
    allsubmodel=infoStruct.modelRefsAll; % all submodels list
    leftsubmodel = setdiff(allsubmodel,htmlsubmodel);
    for i=1:length(leftsubmodel)
        insertLinks = [insertLinks '<TR><TD>' leftsubmodel{i} '</TD><TR>'];
    end    
    rptBuffer = strrep(rptBuffer, '</BODY>', [insertLinks, '</TABLE> </BODY>']);
    fid = fopen(rptContentsFile,'w');
    fprintf(fid, '%s', rptBuffer);
    fclose(fid);
end
