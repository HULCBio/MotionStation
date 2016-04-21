function mxdom2rpt(dom,outputPath)
%MXDOM2RPT Write the DOM out to Report Generator format.
%   MXDOM2RPT(dom,outputPath)

% Copyright 1984-2002 The MathWorks, Inc. 

o = rptgen.coutline('Description','SlideScript report',...
    'RptFileName',outputPath);
currentNode = o;

cellNodeList = dom.getElementsByTagName('cell');
for i = 1:cellNodeList.getLength
    cellNode = cellNodeList.item(i-1);
    
    titleNodeList = cellNode.getElementsByTagName('steptitle');
    if (titleNodeList.getLength > 0)
        title = char(titleNodeList.item(0).getFirstChild.getData);
        if (cellNode.getElementsByTagName('mcode').getLength == 0)
            % TODO: handle title/overview
            %currentNode = rptgen.cfr_titlepage('Title',title),'down');
            currentNode = rptgen.cfr_section('SectionTitle',title);
        else
            currentNode = rptgen.cfr_section('SectionTitle',title);
        end
        connect(o, currentNode, 'down');
    end
    
    % Add text.
    textNodeList = cellNode.getElementsByTagName('text');
    if (textNodeList.getLength == 1)
        textNode = textNodeList.item(0);
        textChildNodeList = textNode.getChildNodes;
        for j = 1:textChildNodeList.getLength
            textChildNode = textChildNodeList.item(j-1);
            switch char(textChildNode.getNodeName)
                case '#text'
                    % Do nothing.  Probably whitespace.
                case 'p'
                    text = '';
                    pChildNodeList = textChildNode.getChildNodes;
                    for k = 1:pChildNodeList.getLength
                        pChildNode = pChildNodeList.item(k-1);
                        switch char(pChildNode.getNodeName)
                            case '#text'
                                nextText = char(pChildNode.getData);
                                nextText = strrep(nextText,char(10),' ');
                                nextText = strrep(nextText,char(13),' ');
                                nextText = fliplr(deblank(fliplr(deblank(nextText))));
                                if ~isempty(nextText)
                                    if ~isempty(text)
                                        text(end+1) = ' ';
                                    end
                                    text = [text nextText];
                                end
                            case 'link'
                                link = char(pChildNode.getFirstChild.getData);
                                text = [text link];
                            otherwise
                                disp(['Not implemented: ' char(pChildNode.getNodeName)]);
                        end
                    end
                    %if isequal(class(section),'rptgen.cfr_titlepage')
                    %set(section,'Abstract',text');
                    %else
                    connect(currentNode, ...
                        rptgen.cfr_paragraph('ParaText',text), ...
                        'down');
                    %end
                otherwise
                    disp(char(textChildNode.getNodeName))
            end
        end
    end
    
    % Add m-code.
    mcodeNodeList = cellNode.getElementsByTagName('mcode');
    if (mcodeNodeList.getLength > 0)
        mcode = char(mcodeNodeList.item(0).getFirstChild.getData);
        connect(currentNode, ...
            rptgen.cml_eval('EvalString',mcode, ...
                'isInsertString',true,'isDiary',true), ...
            'down');
    end

    % Add m-code output.
    mcodeoutputNodeList = cellNode.getElementsByTagName('mcodeoutput');
    if (mcodeoutputNodeList.getLength > 0)
        mcodeoutput = char(mcodeoutputNodeList.item(0).getFirstChild.getData);
        % TODO
    end

    % Add output image.
    imgNodeList = cellNode.getElementsByTagName('img');
    if (imgNodeList.getLength > 0)
        %img = char(imgNodeList.item(0).getAttribute('src'));
        connect(currentNode, ...
            rptgen_hg.chg_fig_snap, ...
            'down');
    end
end

o.save(outputPath);