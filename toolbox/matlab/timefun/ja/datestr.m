% DATESTR   日付の文字列書式
% 
% DATESTR(D,DATEFORM) は、(DATEVECで出力されるような)日付ベクトルまた
% は(DATENUM で出力されるような)シリアルな日付番号 D、またはフリー書式
% 日付文字列を、書式番号または文字列 DATEFORM で指定した書式(下記の表1)
% を使った日付文字列に変換します。デフォルトでは、DATEFORM は、D が日
% 付、時間、あるいは日付と時間の両方のいずれかを含むかにより、1、16、0
% のいずれかです。年を表わす2文字の文字列は、現在の年を中心とした100年
% の以内の年と解釈されます。DATEFORM は、下記の表2のように書式トークン
% で構成される自由形式の日付書式文字列を含むことができます。DATESTR は、
% 指定した自由な日付書式によって日付Dを表わします。
%
% DATESTR(D,DATEFORM,PIVOTYEAR) は、年を表わす2文字の文字列に対しては、
% 100年の範囲の開始年として指定したピボット年を使います。デフォルトの
% ピボット年は、現在の年のマイナス50年です。DATEFORM = -1 は、デフォルト
% の書式を使います。
%
% DATESTR(...,'local') は、ローカライズされた書式で文字列を出力します。
% デフォルト('en_USという名前です')は、US Englishです。この引数は、引
% 数シーケンスの一番最後でなければなりません。
%
% 表1: 標準のMATLAB日付書式定義
%
% DATEFORM番号	     DATEFORM文字列	      例題
% ==================================================================
%      0             'dd-mmm-yyyy HH:MM:SS'   01-Mar-2000 15:45:17 
%      1             'dd-mmm-yyyy'            01-Mar-2000  
%      2             'mm/dd/yy'               03/01/00     
%      3             'mmm'                    Mar          
%      4             'm'                      M            
%      5             'mm'                     03            
%      6             'mm/dd'                  03/01        
%      7             'dd'                     01            
%      8             'ddd'                    Wed          
%      9             'd'                      W            
%     10             'yyyy'                   2000         
%     11             'yy'                     00           
%     12             'mmmyy'                  Mar00        
%     13             'HH:MM:SS'               15:45:17     
%     14             'HH:MM:SS PM'             3:45:17 PM  
%     15             'HH:MM'                  15:45        
%     16             'HH:MM PM'                3:45 PM     
%     17             'QQ-YY'                  Q1-96        
%     18             'QQ'                     Q1           
%     19             'dd/mm'                  01/03        
%     20             'dd/mm/yy'               01/03/00     
%     21             'mmm.dd,yyyy HH:MM:SS'   Mar.01,2000 15:45:17 
%     22             'mmm.dd,yyyy'            Mar.01,2000  
%     23             'mm/dd/yyyy'             03/01/2000 
%     24             'dd/mm/yyyy'             01/03/2000 
%     25             'yy/mm/dd'               00/03/01 
%     26             'yyyy/mm/dd'             2000/03/01 
%     27             'QQ-YYYY'                Q1-1996        
%     28             'mmmyyyy'                Mar2000        
%     29 (ISO 8601)  'yyyy-mm-dd'             2000-03-01
%     30 (ISO 8601)  'yyyymmddTHHMMSS'        20000301T154517 
%     31             'yyyy-mm-dd HH:MM:SS'    2000-03-01 15:45:17 
%
% 表2: 自由形式日付書式シンボル
%   
% シンボル　書式シンボルの解釈
% ===================================================================
% yyyy    4桁の年, 例. 1990, 2000, 2002
% yy      2桁の年, 例. 90, 00, 02
% mmmm    calendar localeに従う月名のフルネーム, 
%         例."March", "April" (UK およびUSA English locales). 
% mmm     calendar localeに従う月名の最初の3文字, 
%	  　例. "Mar", "Apr" (UK およびUSA English locales). 
% mm      先頭にゼロを付加した数値の月, 例. ../03/..  または../12/.. 
% m       calendar localeに従う月名の大文字の頭文字; 下位互換性のため.
% dddd    calendar localeに従う曜日のフルネーム, 
%         例. "Monday", "Tueday" (UK およびUSA calendar locales). 
% ddd     calendar localeに従う曜日の最初の3文字
%	  例. "Mon", "Tue"(UK およびUSA calendar locales). 
% dd      先頭にゼロを付加した日, 例. 05/../..  または 20/../.. 
% d       日の大文字の頭文字; 下位互換性のため
% HH      時間書式に従う時。時間書式AM | PM が設定されている場合は、
%	   HH は先頭にゼロを付加しません。AM | PM が設定されていない
%	   場合は、先頭にゼロを付加して時を表示します。例 10:20 PMは、
%	   22:20; 9:00 AM、および09:00と等価です。
% MM      先頭にゼロを付加した時と分。例. 10:15, 10:05, 10:05 AM.
% SS      先頭にゼロを付加した時/分/秒。例. 10:15:30, 10:05:30, 
%	  10:05:30 AM. 
% PM      午前または午後として時間書式を設定。AM またはPM は、適宜
%	  日付文字列に付加されます。 
%
% 例題:
% DATESTR(now)は、US English localeでは、特定の日付に対して
% '24-Jan-2003 11:58:15' を出力します。
% DATESTR(now,2) は、01/24/03を出力し、DATESTR(now,'mm/dd/yy')と
% 同じです。
% DATESTR(now,'dd.mm.yyyy') は、24.01.2003 を出力します。
% 非標準の日付書式を標準のMATLAB日付書式に変換するには、最初に、DATENUM
% を使って非標準日付書式を日付番号に変換します。
% たとえば、DATESTR(DATENUM('24.01.2003','dd.mm.yyyy'),2) は、01/24/03
% を出力します。
%
% 参考：DATE, DATENUM, DATEVEC, DATETICK.


%   Copyright 1984-2002 The MathWorks, Inc. 
