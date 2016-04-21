% SLUPDATE   旧バージョンのブロックを現バージョンのブロックに置換
%
% SLUPDATE(SYS) は、モデルSYS内の旧バージョンの廃止されたブロックを
% Simulink 4のブロックで置き換えます。モデルは、SLUPDATEを呼び出す前に開いて
% いなければなりません。アップデートされたブロックは以下のとおりです。
%
% Pulse Generator             - 新規インプリメンテーション Hit Crossing
%  - 組み込みになっています S-function Memory           - Memoryブロックは組
%  み込みになって います S-function Quantizer        - 組み込みになっています Gr
%  aph scope                 - 組み込みのScopeはこのブロックを 改良しています
%  S-function 2-D Table Lookup - 組み込みになっています Elementary Mat
%  h             - Trigonometry,Rounding, Mathブロッ クで 置き換えられ
%  ています To Workspace                - Maximum rowsパラメータの3要素
%   バージョンは、個々のフィールドに 分離されています Outport                     -
%                                Initial output を[] で置き換えています。
%
% SLUPDATE(SYS, PROMPT) は、PROMPT の値が1の場合、置換可能なブロックについて
% ユーザに質問します。これはデフォルトです。
% 値が0ならば質問しません。
%
% 質問されたとき、ユーザは3種類のオプションをもちます。
% - "y" : ブロックを置換(デフォルト)- "n" : ブロックを置換しない- "a" : す
% べてのブロックを確認せずに置換
%
% 前述の変更に加えて、SLUPDATE は、ADDTERMS を呼び出して未接続の入力および出
% 力端子を Ground および Terminator ブロックと接続することにより結線します。
% SLUPDATEは、ブロックを適切なブロックライブラリにおけるリンクに変換します。
%
% SLUPDATE は、サブシステム、あるいは、Sファンクションでないすべてのマスクされ
% た組み込みのブロックを検索し、ブロックをサブシステムに置き、マスクとブロッ
% クのコールバックを新しいサブシステムにコピーします。
%
% 参考 : FIND_SYSTEM, GET_PARAM, ADD_BLOCK, ADDTERMS, MOVEMASK.


% Copyright 1990-2002 The MathWorks, Inc.
