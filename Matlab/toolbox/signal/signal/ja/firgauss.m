% FIRGAUSS FIR Gaussian �f�W�^���t�B���^�݌v
% B = FIRGAUSS(K,N) �́AFIR �t�B���^�̐݌v�����܂��B���̃C���p���X����
% �́A���z�I�ȃK�E�X���z���ߎ����܂��B���̃t�B���^�͒���N �� 
% cascading K uniform-coefficient (boxcar) �t�B���^�ɂ���������܂��B
% �t�B���^�S�̂̃C���p���X�����̒����́AK*(N-1)+1�ł��B
% �t�B���^�̌W���́A�x�N�g��B�ɏo�͂���܂��B
%
% [B, N] = FIRGAUSS(K,'minorder',V) �́A���UV�����K�E�X�t�B���^��
% �݌v���܂��B�W���΍��̓��Ƃ��Ē�`�����A���̕��U�́A�X��boxcar
% �t�B���^�̃R���{�����[�V����(�J�X�P�[�h)�̕��U�̘a�ł��B
% K >= 4�̏ꍇ�AFIRGAUSS�́A�eboxcar �t�B���^�̒���N �����肷�邽�߂ɁA 
% �œK�ȃe�N�j�b�N���g�p���܂��B���̍œK�ȃe�N�j�b�N�́A�t�B���^�̃C���p���X
% �����ƁA���z�I�ȃK�E�X���z�Ƃ̊Ԃ̓�敽�ϕ�����(rms)�̍����ŏ��ɂ���K�E�X
% �ߎ��ɂȂ�܂��B 
%
% ���:
%   % ����32��4 boxcar �t�B���^�̃J�X�P�[�h
%   K = 4; N = 32;    
%   b = firgauss(K,N); 
%   fvtool(b);
%
% �Q�l GAUSSWIN, GAUSPULS, GMONOPULS. 

%   Copyright 1988-2002 The MathWorks, Inc.
