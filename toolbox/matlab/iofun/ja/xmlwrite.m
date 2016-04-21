% XMLWRITE   XML Document Object Model nodeをシリアル化
%.
% XMLWRITE(FILENAME,DOMNODE) は、DOMNODEをファイルFILENAMEに
% シリアル化します。.
%
% S = XMLWRITE(DOMNODE) は、文字列としてnode treeを出力します。
%
% 例題:
%   % サンプルのXMLドキュメントを作成.
%   docNode = com.mathworks.xml.XMLUtils.createDocument('root_element')
%   docRootNode = docNode.getDocumentElement;
%   for i=1:20
%      thisElement = docNode.createElement('child_node');
%      thisElement.appendChild(docNode.createTextNode(sprintf('%i',i)));
%      docRootNode.appendChild(thisElement);
%   end
%   docNode.appendChild(docNode.createComment('this is a comment'));
%
%   % サンプルXMLドキュメントを保存
%   xmlFileName = [tempname,'.xml'];
%   xmlwrite(xmlFileName,docNode);
%   edit(xmlFileName);
%
% 参考 ： XMLREAD, XSLT.



%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.3.4.1 $  $Date: 2004/04/28 01:58:38 $
