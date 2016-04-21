% SETPTR   figureのポインタの設定
% 
% SETPTR(FIG,CURSOR_NAME)は、cursor_name に従って、ハンドル番号が FIG
% であるfigureのカーソルを設定します。
% 
%    'hand'       - 手のひら型
%    'hand1'      - 1と書いてある手のひら型
%    'hand2'      - 2と書いてある手のひら型
%    'closedhand' - マウスを押したとき、手を握る
%    'glass'      - 虫眼鏡型
%    'glassplus' - 中央に '+' がある虫眼鏡型
%    'glassminus' - 中央に '-' がある虫眼鏡型
%    'lrdrag'     - 左/右のドラッグのカーソル
%    'ldrag'   - 左ドラッグカーソル
%    'rdrag'   - 右ドラッグカーソル
%    'uddrag'     - 上/下のドラッグのカーソル
%    'udrag'   - 上向きドラッグカーソル
%    'ddrag'   - 下向きドラッグカーソル
%    'add'        - + 符号付き矢印
%    'addzero'    - o 印付きの矢印
%    'addpole'    - 'x'印付きの矢印
%    'eraser'     - イレーサ
%    'help'       - クエスチョンマーク付き矢印
%    [ crosshair | fullcrosshair | {arrow} | ibeam | watch | topl |...
%     topr | botl | botr | left | top | right | bottom | circle | ...
%     cross | fleur ]
%         - 標準のカーソル
%
% SetData = setptr(CURSOR_NAME)は、指定した CURSOR_NAME にポインタを
% 正確に設定するプロパティ名と値の組合わせを含むセル配列を出力します。た
% とえば、つぎのようにします。
% 
%     SetData = setptr('arrow');set(FIG,SetData{:})

%   Author: T. Krauss, 10/95
%   Copyright 1984-2002 The MathWorks, Inc. 
