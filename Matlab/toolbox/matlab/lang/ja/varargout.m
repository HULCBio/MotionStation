% VARARGOUT   �ς̏o�͈����̈ꗗ
% 
% �֐��ɔC�ӂ̐��̏o�͈�����ݒ肷�邱�Ƃ��ł��܂��B�ϐ�VARARGOUT �́A
% �֐��̃I�v�V�����̏o�͈������܂ރZ���z��ł��BVARARGOUT �́A�ŐV��
% �o�͈����Ƃ��Đ錾����A���̓_����̂��ׂĂ̏o�͂��܂Ƃ߂܂��B
% �錾�̒��ł́AVARARGOUT �͏������łȂ���΂Ȃ�܂���(���Ȃ킿�Avarargout)�B
% 
% VARARGOUT�́A�֐����Ăэ��܂��Ƃ��ɏ���������܂���B�֐������^�[��
% ����O�ɁAVARARGOUT���쐬���Ȃ���΂Ȃ�܂���B�쐬�����o�͂̐���
% ���肷�邽�߂ɂ́ANARGOUT ���g���Ă��������B
%
% ���Ƃ��΁A�֐�
%
%     function [s,varargout] = mysize(x)
%     nout = max(nargout,1)-1;
%     s = size(x);
%     for i = 1:nout�Avarargout(i) = {s(i)}; end
%
% �́A�T�C�Y�x�N�g���ƃI�v�V�����Ŋe�X�̃T�C�Y���o�͂��܂��B���̂���
%
%    [s,rows,cols] = mysize(rand(4,5));
%
% �́As = [4 5]�Arows = 4�Acols = 5 ���o�͂��܂��B
%
% �Q�l�FVARARGIN, NARGIN, NARGOUT, FUNCTION, LISTS, PAREN.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:59:34 $
%   Built-in function.
