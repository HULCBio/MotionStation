% FINDALL   ���ׂẴI�u�W�F�N�g�̌���
% 
% ObjList = FINDALL(HandleList) �́A�^����ꂽ Handle �ȉ��̂��ׂĂ�
% �I�u�W�F�N�g�̃��X�g���o�͂��܂��BFINDOBJ���g�p���āAHandleVisibility 
% �� 'off' �ɐݒ肳��Ă��邷�ׂẴI�u�W�F�N�g����������܂��BFINDALL 
% �́AFINDOBJ �̌Ăяo���ƑS�����l�ɌĂяo����܂��B���Ƃ��΁A
% ObjList = findall(HandleList,Param1,Val1,Param2,Val2,...) �ł��B
%
% ���Ƃ��΁A���̂悤�Ɏ��s���Ă݂Ă��������B
%
%   plot(1:10)
%   xlabel xlab
%   a = findall(gcf)
%   b = findobj(gcf)
%   c = findall(b,'Type','text')  % xlabel�̃n���h���ԍ���2��o�͂��܂��B
%   d = findobj(b,'Type','text')  % xlabel�̃n���h���ԍ��͌����ł��܂���B
%
% �Q�l�FALLCHILD, FINDOBJ.


%   Loren Dean
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $ $Date: 2004/04/28 02:08:01 $
