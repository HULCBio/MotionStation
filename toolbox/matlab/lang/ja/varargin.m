% VARARGIN   �ς̓��͈����̈ꗗ
% 
% �֐��ɑ΂��āA�C�ӂ̐��̈�����^���邱�Ƃ��ł��܂��B�ϐ� VARARGIN
% �́A�֐��̃I�v�V�����������܂ރZ���z��ł��BVARARGIN �́A�ŐV�̓�
% �͈����Ƃ��Đ錾����A���̓_����̂��ׂĂ̓��͂��܂Ƃ߂܂��B�錾��
% ���ł́AVARARGIN�͏������łȂ���΂Ȃ�܂���(���Ȃ킿�Avarargin)�B
%
% ���Ƃ��΁A�֐�
%
%     function myplot(x,varargin)
%     plot(x,varargin{:})
%
% �́A2�Ԗڂ̈����ȍ~�̓��͂��A�ϐ�"varargin"�ɂ܂Ƃ߂܂��BMYPLOT �́A
% �J���}�ŋ�؂�ꂽ�V���^�b�N�X varargin{:} ���g���āA�I�v�V������
% �p�����[�^��plot�ɓn���܂��B
%
%     myplot(sin(0:.1:1),'color',[.5 .7 .3],'linestyle',':')
%
% �́A'color'�A[.5 .7 .3]�A'linestyle'�A':'��v�f�Ƃ���1�s4��̃Z���z��
% varargin ���o�͂��܂��B
% 
% �Q�l�FVARARGOUT, NARGIN, NARGOUT, INPUTNAME, FUNCTION, LISTS, PAREN.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:59:33 $
%   Built-in function.

