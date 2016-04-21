% IMNOISE   �C���[�W�Ƀm�C�Y��t��
%   J = IMNOISE(I,TYPE,...) �́A���x�C���[�W I �� TYPE �Őݒ肵���m�C
%   �Y��t�����܂��BTYPE �ɂ́A���̂����ꂩ��ݒ肷�邱�Ƃ��ł���
%   ���B
%
%       'gaussian'       ��l�̕��ςƕ��U�����K�E�X���F�m�C�Y
%                        mean and variance
%
%       'localvar'       ���x�Ɉˑ��������U�������ς��[���� Gaussian 
%                        ���F�m�C�Y
%
%       'poisson'        Poisson noise
%
%       'salt & pepper'  �s�N�Z���� on �� off �̍��݂����m�C�Y
%
%       'speckle'        �ݐϓI�ȃm�C�Y
%
%   TYPE �Ɋ�Â��āAIMNOISE �ɒǉ��̃p�����[�^��ݒ肷�邱�Ƃ��ł��܂��B
%   ���ׂĂ̐��l�p�����[�^�͐��K������Ă��܂��B�����́A0 ���� 1 �̋�
%   �x�͈̔͂����C���[�W�ւ̉��Z�ɑΉ��������̂ł��B
%   
%   J = IMNOISE(I,'gaussian',M,V) �́A�C���[�W I �ɕ��ϒl M�A���U V ��
%   �K�E�X���F�m�C�Y��t�����܂��B�f�t�H���g�l�́AV ��0.01�ŁAM ��0��
%   ���B
%   
% J = imnoise(I,'localvar',V) �́A�C���[�W I �ɁA���ϒl0�A�Ǐ��I�ȃK�E
% �X���F�m�C�Y V �������܂��BV �́AI �Ɠ����T�C�Y�̔z��ł��B
%
% J = imnoise(I,'localvar',IMAGE_INTENSITY,VAR) �́A�C���[�W I �Ƀ[����
% �ρA�K�E�X�m�C�Y�������܂��B�����ŁA�m�C�Y�̃��[�J�����U�́AI �̃C��
% �[�W�̋��x�l�̊֐��ł��BIMAGE_INTENSITY �� VAR �́A�����T�C�Y�̃x�N�g
% ���ŁAPLOT(IMAGE_INTENSITY,VAR) �́A�m�C�Y�̕��U�ƃC���[�W���x�̊֐�
% �֌W���v���b�g�\�����܂��B
% IMAGE_INTENSITY �́A0��1�͈̔͂̐��K�����ꂽ���x�l�ł��B
%
% J = IMNOISE(I,'poisson') �́A�f�[�^�ɐl�H�I�ȃm�C�Y��������̂ł͂Ȃ��A
% �f�[�^���� Poisson �m�C�Y���쐬���܂��BPoisson ���v�ʂɂ��ẮAuint8 
% �� uint16 �̃C���[�W�̋��x�́A�t�H�g���̐��ɑΉ����Ă���Ƃ��܂��B
% �{���x�̃C���[�W�́A�s�N�Z��������̃t�H�g���̐�65535 ��葽���ꍇ�Ɏg
% ���܂��B���Ȃ킿�A���x�l�́A0 �� 1 �̊Ԃŕω����鋭�x�l�ŁA10^12 �ŏ�
% �Z�����t�H�g���̐��ɑΉ����܂��B
%
% J = IMNOISE(I,'salt & pepper',D) �́A�C���[�WI�ɌӖ����m�C�Y��t������
% ���B�����ŁAD �̓m�C�Y���x�ł��B����́A�ߎ��I�ɁAD*PROD(SIZE(I)) �s�N
% �Z���ɉe����^���܂��B�f�t�H���g�l�́A0.05�m�C�Y���x�ł��B
%   
% J = IMNOISE(I,'speckle',V) �́A�C���[�W I �ɗݐσm�C�Y��t�����܂��B��
% ���ł́A�� J = I+n*I ���g���܂��B�����ŁAn �́A���ς�0�A���U�� V �̈�
% �l���z�����ł��BV �ɑ΂���f�t�H���g��0.04�ł��B
%   
% �N���X�T�|�[�g
% -------------
% ���̓C���[�W I �́Auint8�Auint16�A�܂��́Adouble �̂�����̃N���X
% ���T�|�[�g���Ă��܂��B�o�̓C���[�W J �́AI �Ɠ����N���X�ɂȂ��
% ���B I ���A2�����ȏ�̏ꍇ�A���������x�C���[�W�Ƃ��Ď�舵���܂����A
% RGB �C���[�W�̂悤�ɂ́A�����܂���B
%
% ���
% ----
%        I = imread('eight.tif');
%        J = imnoise(I,'salt & pepper', 0.02);
%        imshow(I), figure, imshow(J)
%
% �Q�l�FIMNSTATS, RAND, RANDN



%   Copyright 1993-2002 The MathWorks, Inc.  
