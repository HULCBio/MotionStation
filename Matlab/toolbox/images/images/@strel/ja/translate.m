% TRANSLATE �\�����v�f�̕ϊ�
% SE2 = TRANSLATE(SE,V) �́AN-������Ԃ̍\�����v�f SE ��ϊ����܂��BV 
% �́A�e�����̒��ŁA��]����ϊ��̃I�t�Z�b�g���܂� N �v�f�̃x�N�g���ł��B
%
% ���
%   -------
% STREL(1) �̕ϊ����ꂽ�o�[�W�������g�����c���́A��ԓ��ŁA���̓C���[�W��
% �ϊ������̕��@�ł��B���̗��́Acameraman.tif �C���[�W���A25 �s�N�Z
% ���̐����`�ɕϊ�������̂ł��B
%
%       I = imread('cameraman.tif');
%       se = translate(strel(1), [25 25]);
%       J = imdilate(I,se);
%       imshow(I), title('Original')
%       figure, imshow(J), title('Translated');
%
% �Q�l�FSTREL, STREL/REFLECT.



% $Revision: 1.1 $
%   Copyright 1993-2002 The MathWorks, Inc.
