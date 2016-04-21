% STR2FUNC   �֐����̕����񂩂�֐��n���h��(function_handle)���\�z
%
% FUNHANDLE = STR2FUNC(S) �́A������ S ���̊֐�������֐��n���h��
% (function_handle) FUNHANDLE ���\�z���܂��B
%
% @function �\�����ASTR2FUNC �R�}���h�̂ǂ��炩��p���Ċ֐��n���h����
% �쐬���邱�Ƃ��ł��܂��B������̃Z���z��ł��̑�������s���邱�Ƃ�
% �\�ł��B���̏ꍇ�A�֐��n���h���̔z�񂪏o�͂���܂��B
%
% ���:
%
% �֐��� 'humps' ����֐��n���h�����쐬���܂��B:
%
%        fhandle = str2func('humps')
%        fhandle = 
%            @humps
%
% �֐����̃Z���z�񂩂�֐��n���h���̔z����쐬���܂�:
%
%        fh_array = str2func({'sin' 'cos' 'tan'})
%        fh_array = 
%            @sin    @cos    @tan
%
% �Q�l: FUNCTION_HANDLE, FUNC2STR, FUNCTIONS.



%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $ $Date: 2004/04/28 01:47:50 $
