function mxdom2word(dom,outputPath)
%MXDOM2WORD Write the DOM out to a Word document.
%   MXDOM2WORD(dom,outputPath)

% Matthew J. Simoneau
% Copyright 1984-2004 The MathWorks, Inc. 

if ~ispc
    error('MATLAB:publish:NoWord','Publishing to Microsoft Word is only supported on the PC.')
end
try
    wordApplication=actxserver('Word.Application');
catch
    error('MATLAB:publish:NoWord','Microsoft Word must be installed to publish to this format.')
end

wdStyleNormal = -1;
wdStyleHeading1 = -2;
wdStyleHeading2 = -3;

%set(wordApplication,'Visible',1);
documents = wordApplication.Documents;
doc = documents.Add;
selection = wordApplication.Selection;

style = wordApplication.ActiveDocument.Styles.Add('M-code');
set(style,'NoProofing',true);
set(style.Font,'Name','Lucida Console','Size',8,'Bold',true)
set(style.ParagraphFormat,'LeftIndent',30)

style = wordApplication.ActiveDocument.Styles.Add('output');
set(style,'NoProofing',true);
set(style.Font,'Name','Lucida Console','Size',8,'Italic',true,'Color','wdColorGray80')

cellNodeList = dom.getElementsByTagName('cell');

[hasIntro,hasSections] = getStructure(cellNodeList);

for i = 1:cellNodeList.getLength
    cellNode = cellNodeList.item(i-1);
   
    % Table of contents.
    if hasSections && ...
          (((i == 1) && ~hasIntro) || ((i == 2) && hasIntro))
        toc = wordApplication.ActiveDocument.TablesOfContents.Add(selection.Range);
        set(toc,'UpperHeadingLevel',2)
        set(toc,'LowerHeadingLevel',2)
        selection.EndKey
        selection.MoveDown
        selection.TypeParagraph;
        addTableOfContents = false;       
    end
   
    % Add title.
    titleNodeList = cellNode.getElementsByTagName('steptitle');
    if (titleNodeList.getLength > 0)
        titleNode = titleNodeList.item(0);
        title = char(titleNode.getFirstChild.getData);
        switch char(titleNode.getAttribute('style'))
           case 'document'
              set(selection,'Style',wdStyleHeading1)
           otherwise
              set(selection,'Style',wdStyleHeading2)
        end
        selection.TypeText(title)
        selection.TypeParagraph;
        set(selection,'Style',wdStyleNormal) 
    end
    
    % Add text.
    textNodeList = cellNode.getElementsByTagName('text');
    if (textNodeList.getLength == 1)
        textNode = textNodeList.item(0);
        addTextNode(textNode,selection,wordApplication,outputPath);
    end
    
    % Add m-code.
    mcodeNodeList = cellNode.getElementsByTagName('mcode');
    if (mcodeNodeList.getLength > 0)
        mcode = char(mcodeNodeList.item(0).getFirstChild.getData);
        set(selection,'Style','M-code')
        selection.TypeText(mcode)
        selection.TypeParagraph;
        set(selection,'Style',wdStyleNormal)
        selection.TypeParagraph;
    end

    % Add m-code output.
    mcodeoutputNodeList = cellNode.getElementsByTagName('mcodeoutput');
    if (mcodeoutputNodeList.getLength > 0)
        mcodeoutput = char(mcodeoutputNodeList.item(0).getFirstChild.getData);
        set(selection,'Style','output')
        selection.TypeText(mcodeoutput)
        selection.TypeParagraph;
        set(selection,'Style',wdStyleNormal)
        selection.TypeParagraph;
    end

    % Add output image.
    childNode = cellNode.getFirstChild;
    while ~isempty(childNode)
       if isequal(char(childNode.getNodeName),'img')
          img = char(childNode.getAttribute('src'));
          selection.InlineShapes.AddPicture([tempdir img]);
          selection.TypeParagraph;
          selection.TypeParagraph;
       end
       childNode = childNode.getNextSibling;
    end
end

% Copyright footer.
copyrightList = dom.getElementsByTagName('copyright');
if (copyrightList.getLength > 0)
   copyright = char(copyrightList.item(0).getFirstChild.getData);
   selection.Font.Italic = true;
   selection.TypeText(copyright)
   selection.Font.Italic = false;
end


% Refresh the Table of Contents
if hasSections
   toc.Update;
end

% Return to the top of the document.
%invoke(selection,'GoTo',0);

try
    doc.SaveAs(outputPath);
catch
    if ~isempty(strfind(lasterr,'already open elsewhere'))
        str = 'Could not create the file "%s" because there is already a copy open in Word.  Close the document and try again.';
        errordlg(sprintf(str,outputPath),'Publishing Error');
        error(sprintf(str,outputPath));
    else
        error(lasterr);
    end
end
doc.Close(0);
wordApplication.Quit


%===============================================================================
function addTextNode(textNode,selection,wordApplication,outputPath)
textChildNodeList = textNode.getChildNodes;
for j = 1:textChildNodeList.getLength
   textChildNode = textChildNodeList.item(j-1);
   switch char(textChildNode.getNodeName)
      case 'p'
         addText(textChildNode,selection,wordApplication,outputPath)
         selection.TypeParagraph;
         selection.TypeParagraph;
      case 'ul'
         pChildNodeList = textChildNode.getChildNodes;
         selection.Range.ListFormat.ApplyBulletDefault
         for k = 1:pChildNodeList.getLength
            liNode = pChildNodeList.item(k-1);
            addText(liNode,selection,wordApplication,outputPath)
            selection.TypeParagraph;
         end
         selection.Range.ListFormat.RemoveNumbers;
         selection.TypeParagraph;
      case 'pre'
         font = selection.Font;
         ttProps = {'Name','Size'};
         ttVals = {'Lucida Console',10};
         orig = get(font,ttProps);
         set(font,ttProps,ttVals)
         addText(textChildNode,selection,wordApplication,outputPath)
         set(font,ttProps,orig)
         selection.TypeParagraph;
         selection.TypeParagraph;
      otherwise
         disp(['Not implemented: ' char(textChildNode.getNodeName)])
   end
end

%===============================================================================
function addText(textChildNode,selection,wordApplication,outputPath)
pChildNodeList = textChildNode.getChildNodes;
for k = 1:pChildNodeList.getLength
   pChildNode = pChildNodeList.item(k-1);
   switch char(pChildNode.getNodeName)
      case '#text'
         nextText = char(pChildNode.getData);
         selection.TypeText(nextText)
      case 'a'
         aHref = char(pChildNode.getAttribute('href'));
         aText = char(pChildNode.getFirstChild.getData);
         hyperLinks = wordApplication.ActiveDocument.Hyperlinks;
         hyperLinks.Add(selection.Range,aHref,'',aHref,aText);
      case 'b'
         nextText = char(pChildNode.getFirstChild.getData);
         selection.Font.Bold = true;
         selection.TypeText(nextText)
         selection.Font.Bold = false;
      case 'tt'
         nextText = char(pChildNode.getFirstChild.getData);
         font = selection.Font;
         ttProps = {'Name','Size'};
         ttVals = {'Lucida Console',10};
         orig = get(font,ttProps);
         set(font,ttProps,ttVals)
         selection.TypeText(nextText)
         set(font,ttProps,orig)
      case 'img'
         u = toURI(java.io.File(outputPath));
         src = char(pChildNode.getAttribute('src'));
         u = u.resolve(src);
         switch char(u.getScheme)
            case 'file'
               f = java.io.File(u);
               toInclude = char(f.toString);
               selection.InlineShapes.AddPicture(toInclude);
            otherwise
               toInclude = tempname;
               urlwrite(char(u.toString),toInclude);
               selection.InlineShapes.AddPicture(toInclude);
               delete(toInclude)
         end
      case 'equation'
         equationImage = char(pChildNode.getFirstChild.getAttribute('src'));
         equationText = char(pChildNode.getAttribute('text'));
         inlineShape = selection.InlineShapes.AddPicture(equationImage);
         inlineShape.AlternativeText = equationText;
      otherwise
         disp(['Not implemented: ' char(pChildNode.getNodeName)]);
   end
end


%===============================================================================
function [hasIntro,hasSections] = getStructure(cellNodeList)

hasIntro = false;
if (cellNodeList.getLength > 0)
   style = char(cellNodeList.item(0).getAttribute('style'));
   if isequal(style,'overview')
      hasIntro = true;
   end
end

hasSections = false;
for i = 1:cellNodeList.getLength
   cellNode = cellNodeList.item(i-1);
   titleNodeList = cellNode.getElementsByTagName('steptitle');
   if (titleNodeList.getLength > 0)
      titleNode = titleNodeList.item(0);
      style = char(titleNode.getAttribute('style'));
      if ~isequal(style,'document')
         hasSections = true;
         break
      end
   end
end