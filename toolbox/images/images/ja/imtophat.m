% IMTOPHAT  Top hat �t�B���^����
% IM2 = IMTOPHAT(IM,SE) �́A�O���[�X�P�[���A�܂��́A�o�C�i�����̓C���[�W 
% IM �ɁA�\�����v�f SE ���g���āA�`�Ԋw�I�� top hat �t�B���^�����K�p��
% �܂��BSE �́A�֐� STREL �ŏo�͂����\�����v�f�ł��BSE �́A�P��̍\��
% ���v�f�I�u�W�F�N�g�ŁA�����̍\�����v�f�I�u�W�F�N�g���܂ޔz��ł͂����
% ����B
%
% IM2 = IMTOPHAT(IM,NHOOD) �́A�`�Ԋw�I top hat �t�B���^������s���܂��B
% �����ŁANHOOD �́A�\�����v�f�̃T�C�Y�ƌ^��ݒ肷��0��1�̗v�f�݂̂ō쐬
% ����Ă���z��ł��B����́AIMTOPHAT(IM,STREL(NHOOD)) �Ɠ����ł��B
%
% �N���X�T�|�[�g
% -------------
% IM �́A���l�܂��� logical �Ŕ�X�p�[�X�łȂ���΂Ȃ�܂���B�o��
% �C���[�W�́A���̓C���[�W�Ɠ����N���X�ɂȂ�܂��B���͂��o�C�i���C���[
% �W(logical)�̏ꍇ�A�\�����v�f�͕��R�łȂ���΂Ȃ�܂���B
%
% ���
% -------
% Tophat �t�B���^����́A�o�b�N�O�����h���Â��ꍇ�ɁA�s�ώ��ȏƓx��␳��
% �邽�߂Ɏg���܂��B���̗��́Arice.tif �C���[�W����s�ώ��ȃo�b�N�O��
% ���h�Ɠx���������邽�߂ɁA�~�Ղ��g���āAtophat �t�B���^������s���܂��B
% �����āAimadjust �� stretchlim ���g���āA���ʂ����ȒP�ɉ������܂��B
%
%   I = imread('rice.tif');
%   imshow(I), title('Original')
%   se = strel('disk',12);
%   J = imtophat(I,se);
%   figure, imshow(J), title('Step 1: Tophat filtering')
%   K = imadjust(J,stretchlim(J));
%   figure, imshow(K), title('Step 2: Contrast adjustment')
%
% �Q�l�F IMBOTHAT, STREL.



%   Copyright 1993-2002 The MathWorks, Inc.  
