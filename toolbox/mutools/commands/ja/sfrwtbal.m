% function [sys1,sig1] = sfrwtbal(sys,wt1,wt2);
%
% MINV(WT1~)*SYS*MINV(wt2~)�̈��蕔���v�Z���ASYS1�͂��̕��t�������ŁA
% Hankel���ْlSYS1�������܂��BWT1��WT2�́ASYS�Ɠ��������̈���ȍŏ���
% ���A�����s��łȂ���΂Ȃ�܂���BWT2�̃f�t�H���g�l�͒P�ʍs��ŁASYS
% �͈���łȂ���΂Ȃ�܂���B
%
% SYS1(k)�́A�덷MINV(WT1~)*(SYS-SYSHAT)*MINV(WT2~)�̒B���\��H���m����
% �̉��E�ł��B�����ŁASYSHAT�͎���K�ň���ł��B���[�`���́A���̂悤��
% SYSHAT�𓾂邽�߂ɁASFRWTBLD�Ƌ��Ɏg���܂��B
%
%   >>[sys1,sig1] = sfrwtbal(sys,wt1,wt2);
%   >>sys1hat = strunc(sys1,k);
% �܂��́A
%   >>sys1hat = hankmr(sys1,sig1,k);
%   >>syshat = sfrwtbld(sys1hat,wt1,wt2);
%
% ���ʂ̌덷�́A���g�������̌v�Z�𒼐ڎg���ĕ]������܂��B
%
% �Q�l: HANKMR, SFRWTBLD, SNCFBAL, SRELBAL, SYSBAL, SRESID, TRUNC.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
