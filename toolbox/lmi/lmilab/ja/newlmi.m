% lmitag = newlmi
%
% カレントに記述されている連立LMIに新規のLMIを追加し、識別子LMITAGを付加
% します。
% 
% この識別子は、後に続くLMITERTM, DELLMI, SHOWLMIコマンドで新規のLMIを参
% 照するために使います。
%
% NEWLMIを使って連立LMIを宣言することは、オプションで、コードを読み易く
% するためだけにあります。
%
% 出力:
%  LMITAG     新規のLMIの識別子。システム内にL-1個の連立LMIが既にあれば
%             その値は、Lです。この値は、後で連立LMIが変更されても、その
%             ままです。
%
% 参考：    SETLMIS, LMIVAR, LMITERM, GETLMIS, LMIEDIT.



% Copyright 1995-2002 The MathWorks, Inc. 
