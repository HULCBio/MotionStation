% WENERGY2   2�����E�F�[�u���b�g�����ɑ΂���G�l���M
%
% 2�����E�F�[�u���b�g���� [C,S] �ɑ΂���(WAVEDEC2 ���Q��)�A
% [Ea,Eh,Ev,Ed] = WENERGY2(C,S) �́Aapproximation �ɑΉ�����G�l���M��
% �p�[�Z���e�[�W Ea �ƁA�����A�����A�Ίp�� detail �ɑΉ�����G�l���M��
% �x�N�g�� Eh, Ev, Ed ���o�͂��܂��B
%
% [Ea,EDetail] = WENERGY2(C,S) �́A�x�N�g�� Eh�AEv ����� Ed �̘a�ł���
% EDetail �ƁAEa ���o�͂��܂��B
%
% ���:
%     load detail
%     [C,S] = wavedec2(X,2,'sym4');
%     [Ea,Eh,Ev,Ed] = wenergy2(C,S)
%     [Ea,EDetails] = wenergy2(C,S)


%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2003/04/18 18:11:59 $
