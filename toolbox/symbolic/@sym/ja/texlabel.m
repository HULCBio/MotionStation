% TEXLABEL �����񂩂� TeX �t�H�[�}�b�g���o��
% TEXLABEL(f) �́Af ���^�C�g���⃉�x���p�� TeX �\���ɕϊ����܂��B�M���V
% ���ϐ������ۂ̃M���V�������Ƃ���(�^�C�g���⃉�x����)�o�͂��邽�߂ɁA��
% �����s���܂��B
%
% �v���b�g�E�B���h�E�ɑ΂��ă^�C�g���⃉�x������������ꍇ�A���̓�������
% �����A�����...�����ĕ\���܂��B
%
% TEXLABEL �́AEZSURF �� EZMESH �ȂǂŁA�^�C�g���� x, y, z ���x����\��
% ���邽�߂� TeX �\�����쐬���邽�߂ɗp�����܂��B
%
% ���:
%    syms x y lambda12 delta
%    texlabel(sin(sqrt(x^2 + y^2))/sqrt(x^2 + y^2))�́A
%    {sin}(({x}^{2}+{y}^{2})^{{1}/{2}})/({x}^{2}+{y}^{2})^{{1}/{2}}
%     ���o�͂��܂��B
%
%    texlabel(3*(1-x)^2*exp(-(x^2) - (y+1)^2) - 10*(x/5 - x^3 - y^5)...
%    * exp(-x^2-y^2) - 1/3*exp(-(x+1)^2 - y^2))�́A{3} ({1}-{x})^{2}...
%    {exp}(-({x}^{2}) - ({y}+{1})^{2}) -...- {1}/{3} {exp}(-({x}+{1})...
%    ^{2} - {y}^{2})���o�͂��܂��B
%
%    texlabel(lambda12^(3/2)/pi - pi*delta^(2/3))�́A{\lambda_{12}}^...
%    {{3}/{2}}/{\pi} - {\pi} {\delta}^{{2}/{3}}���o�͂��܂��B
%
%    texlabel(lambda12^(3/2)/pi - pi*delta^(2/3),'literal')�́A{lambda-
%    12}^{{3}/{2}}/{pi} - {pi} {delta}^{{2}/{3}}���o�͂��܂��B



%   Copyright 1993-2002 The MathWorks, Inc.
