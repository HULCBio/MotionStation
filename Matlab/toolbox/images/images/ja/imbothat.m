% IMBOTHAT Bottom hat �t�B���^����
% IM2 = IMBOTHAT(IM,SE) �́A�O���[�X�P�[���A�܂��́A�o�C�i�����̓C���[�W
% IM �ɁA�\�����v�f SE ���g���āA�`�Ԋw�I�� bottom hat �t�B���^�����K
% �p���܂��BSE �́A�֐� STREL �ŏo�͂����\�����v�f�ł��BSE �́A�P���
% �\�����v�f�I�u�W�F�N�g�ŁA�����̍\�����v�f�I�u�W�F�N�g���܂ޔz��ł͂�
% ��܂���B
%
% IM2 = IMBOTHAT(IM,NHOOD) �́A�`�Ԋw�I bottom hat �t�B���^������s����
% ���B�����ŁANHOOD �́A�\�����v�f�̃T�C�Y�ƌ^��ݒ肷��0��1�̗v�f�̂�
% �ō쐬����Ă���z��ł��B����́AIMBOTHAT(IM,STREL(NHOOD)) �Ɠ�����
% ���B
%
% �N���X�T�|�[�g
% -------------
% IM �́A���l�܂��� logical �ŁA��X�p�[�X�łȂ���΂Ȃ�܂���B�o��
% �C���[�W�́A���̓C���[�W�Ɠ����N���X�ł��B���͂��o�C�i��(logical)��
% �ꍇ�A�\�����v�f�͕��R�łȂ���΂Ȃ�܂���B
%
% ���
% -------
% Tophat �� bottom-hat �t�B���^����́A���ɁA�C���[�W���̃R���g���X�g��
% ����������̂ł��B��@�́A�I���W�i���C���[�W�� tophat �ł̃t�B���^����
% �O���s�����C���[�W�ɉ����A���̌�Abottom-hat �ł̃t�B���^�����O���s����
% �C���[�W�������܂��B
%
%       I = imread('pout.tif');
%       se = strel('disk',3);
%       J = imsubtract(imadd(I,imtophat(I,se)), imbothat(I,se));
%       imshow(I), title('Original')
%       figure, imshow(J), title('Contrast filtered')
%
% �Q�l�FIMTOPHAT, STREL.



%   Copyright 1993-2002 The MathWorks, Inc.  
