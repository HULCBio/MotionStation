% TEXLABEL   �L�����N�^�����񂩂�TeX�t�H�[�}�b�g���쐬
% 
% TEXLABEL(f) �́A�\�� f ���^�C�g��/���x���A�v���P�[�V�����p�ɓ�����TeX��
% �ϊ����܂��B�ϊ����ꂽGreek�ϐ������ۂ̃M���V�������Ƃ���(�^�C�g��/���x��
% ��)������邽�߂̏������s���܂��B
%
% TEXLABEL(f,'literal') �́A�����̃��x����������܂��B
%
% �^�C�g��/���x�����v���b�g�E�B���h�E�ɑ΂��Ē�������ꍇ�́A���̒���������
% ����āA�ȗ������� ...���}������܂��B
%
% TEXLABEL �́AEZSURF�AEZMESH ���Ŏg�p����A�����̃v���b�g��x�Ay�Az��
% �̃��x���ɑ΂���TeX�t�H�[�}�b�g���쐬���܂��B
%
% ���:
% 
%  texlabel('sin(sqrt(x^2 + y^2))/sqrt(x^2 + y^2)')
% 
% �́A�����o�͂��܂��B
% 
%  {sin}({sqrt}({x}^{2} + {y}^{2}))/{sqrt}({x}^{2} + {y}^{2})
%
%  texlabel(['3*(1-x)^2*exp(-(x^2) - (y+1)^2) - ....
%    10*(x/5 - x^3 - y^5)*' 'exp(-x^2-y^2) - 1/3*exp(-(x+1)^2 - y^2)'])
% 
% �́A�����o�͂��܂��B
% 
% {3}({1}-{x})^{2}{exp}(-({x}^{2}) - ({y}+{1})^{2}) -...
%                         - {1}/{3}{exp}(-({x}+{1})^{2}-{y}^{2})
%
%  texlabel('lambda12^(3/2)/pi - pi*delta^(2/3)')
% 
% �́A�����o�͂��܂��B
% 
%  {\lambda_{12}}^{{3}/{2}}/{\pi} - {\pi} {\delta}^{{2}/{3}}
%
%  texlabel('lambda12^(3/2)/pi - pi*delta^(2/3)','literal')
% 
% �́A�����o�͂��܂��B
% 
%  {lambda12}^{{3}/{2}}/{pi} - {pi} {delta}^{{2}/{3}}


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.11.4.1 $  $Date: 2004/04/28 01:54:18 $