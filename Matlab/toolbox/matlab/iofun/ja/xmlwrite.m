% XMLWRITE   XML Document Object Model node���V���A����
%.
% XMLWRITE(FILENAME,DOMNODE) �́ADOMNODE���t�@�C��FILENAME��
% �V���A�������܂��B.
%
% S = XMLWRITE(DOMNODE) �́A������Ƃ���node tree���o�͂��܂��B
%
% ���:
%   % �T���v����XML�h�L�������g���쐬.
%   docNode = com.mathworks.xml.XMLUtils.createDocument('root_element')
%   docRootNode = docNode.getDocumentElement;
%   for i=1:20
%      thisElement = docNode.createElement('child_node');
%      thisElement.appendChild(docNode.createTextNode(sprintf('%i',i)));
%      docRootNode.appendChild(thisElement);
%   end
%   docNode.appendChild(docNode.createComment('this is a comment'));
%
%   % �T���v��XML�h�L�������g��ۑ�
%   xmlFileName = [tempname,'.xml'];
%   xmlwrite(xmlFileName,docNode);
%   edit(xmlFileName);
%
% �Q�l �F XMLREAD, XSLT.



%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.3.4.1 $  $Date: 2004/04/28 01:58:38 $
