% PARSEVARTEXT
% 
%   PARSEDTEXT=PARSEVARTEXT(RPTCOMPONENT,RAWTEXT)
% 
% 生テキスト内の%<varname>を探します。ベースワークスペースで"varname"を
% 評価します。評価が正しく行われ、変数を出力する場合は、結果と%<varname>
% を置き換えます。
% 
% たとえば、ワークスペース内の唯一の変数が"A"で"very"と等しく、RAWTEXTが
% "I am the <A> model of %<B>"である場合、PARSEDTEXTは"I am the very mo-
% del of %<B>"として出力されます。
%
% %<help('magic')>または%<length([1 2 3 4 5])>のようなステートメントを評
% 価内に含めることも可能です。





% $Revision: 1.1.6.1 $ $Date: 2004/03/21 22:21:02 $
%   Copyright 1997-2002 The MathWorks, Inc.
