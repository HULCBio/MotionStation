% DATETICK   日付を書式化した目盛りのラベルを付ける 
% 
% DATETICK(TICKAXIS,DATEFORM) は、指定した軸の目盛りに、日付を書式化した
% 目盛りラベルを付け加えます。TICKAXIS は、文字列 'x','y','z' のいずれかで
% なければなりません。デフォルトは、'x' です。ラベルは、書式番号または
% 文字列 DATEFORM(下の表を参照)に従って書式化されます。DATEFORM の引数が
% 入力されなければ、DATETICK は指定された軸内のオブジェクトに対するデータ
% に基づいて推測します。正しく出力するためには、指定した軸に対するデータは、
% (DATENUM で出力するような)シリアルな日付番号でなければなりません。
%
% DATEFORM番号         DATEFORM文字列	     例題
%      0             'dd-mmm-yyyy HH:MM:SS'   01-Mar-2000 15:45:17 
%      1             'dd-mmm-yyyy'            01-Mar-2000  
%      2             'mm/dd/yy'               03/01/00     
%      3             'mmm'                    Mar          
%      4             'm'                      M            
%      5             'mm'                     3            
%      6             'mm/dd'                  03/01        
%      7             'dd'                     1            
%      8             'ddd'                    Wed          
%      9             'd'                      W            
%     10             'yyyy'                   2000         
%     11             'yy'                     00           
%     12             'mmmyy'                  Mar00        
%     13             'HH:MM:SS'               15:45:17     
%     14             'HH:MM:SS PM'             3:45:17 PM  
%     15             'HH:MM'                  15:45        
%     16             'HH:MM PM'                3:45 PM     
%     17             'QQ-YY'                  Q1-01        
%     18             'QQ'                     Q1        
%     19             'dd/mm'                  01/03        
%     20             'dd/mm/yy'               01/03/00     
%     21             'mmm.dd,yyyy HH:MM:SS'   Mar.01,2000 15:45:17 
%     22             'mmm.dd,yyyy'            Mar.01,2000  
%     23             'mm/dd/yyyy'             03/01/2000 
%     24             'dd/mm/yyyy'             01/03/2000 
%     25             'yy/mm/dd'               00/03/01 
%     26             'yyyy/mm/dd'             2000/03/01 
%     27             'QQ-YYYY'                Q1-2001        
%     28             'mmmyyyy'                Mar2000       
%
% DATETICK(...,'keeplimits') は、軸の範囲を保持して、目盛りラベルを日付を
% ベースにしたラベルに変えます。
% 
% DATETICK(...,'keepticks') は、目盛りラベルの位置を変えないで、日付
% ベースのラベルを変更します。'keepticks' と 'keeplimits' は、同時に使う
% ことはできません。
%
% DATETICK(AX,...) は、カレントaxesではなく指定したaxesを利用します。
%
% DATETICK は、日付番号を日付文字列に変換するために DATESTR を呼び出します。
%
% 例題(1990年の米国の人口に基づく):
% 
%    t = (1900:10:1990)';      %  時間区間
%    p = [75.995 91.972 105.711 123.203 131.669 ...
%        150.697 179.323 203.212 226.505 249.633]';     % 人口
%    plot(datenum(t,1,1),p)   % 年を数値データに変換してプロットします。
%    datetick('x','yyyy')     %  x軸の目盛りを4桁の年のラベルに置き換えます。
%    
% 参考：DATESTR, DATENUM.


%   Author(s): C.F. Garvin, 4-03-95, Clay M. Thompson 1-29-96
%   Copyright 1984-2002 The MathWorks, Inc. 
