% IMTRANSFORM  2 ������ԕϊ����C���[�W�ɓK�p
%
% B = IMTRANSFORM(A,TFORM) �́ATFORM �Œ�`����2������ԕϊ��ɏ]���āA�C
% ���[�W A ��ϊ����܂��BTFORM �́AMAKETFORM�A�܂��́ACP2TFORM �ŏo�͂���
% ��tform �^�ł��Bndims(A) > 2 �̏ꍇ�A���Ƃ��΁ARGB �C���[�W�̏ꍇ�A����
% 2�����ϊ����A��荂�������ɉ����āA���ׂĂ�2�������ʂɎ����I�ɓK�p����
% �܂��B
%
% ���̃V���^�b�N�X���g�p����ꍇ�AIMTRANSFORM�́A�ϊ����ꂽ�C���[�W���A
% �ł��邾���A���o�����邽�߂ɁA�o�̓C���[�W�̌��_�������I�ɃV�t�g���܂��B
% �C���[�W�����W�X�g���[�V�������邽�߂ɁAIMTRANSFORM���g�p���Ă���ꍇ�A
% ���̃V���^�b�N�X�́A���҂��錋�ʂ�^���Ȃ��ł��傤�B'XData' ����� 'YData'
% �𖾎��I�ɐݒ肵�����ꍇ�����邩������܂���B���3�Ɠ��l�ɁA'XData' �� 
% 'YData'�ɂ��Ẳ��L�̋L�q���Q�Ƃ��Ă��������B
%
% B = IMTRANSFORM(A,TFORM,INTERP) �́A�g�p������}�̌^��ݒ�ł��܂��B
% INTERP �́A������ 'nearest', 'bilinear', 'bicubic' �̂����ꂩ��ݒ��
% ���܂��B�܂��AINTERP �́AMAKEERESAMPLER �ɂ��o�͂����\���� RESAM-
% PLER �ł��\���܂���B���̃I�v�V�����́A���T���v�����O�̕��@�����R��
% �g���[��������̂ł��BINTERP �̃f�t�H���g�l�́A'bilinear'�ł��B
%
% [B,XDATA,YDATA] = IMTRANSFORM(...) �́A�o�� X-Y ���ʂɏo�̓C���[�W B 
% �̈ʒu���o�͂��܂��BXDATA �� YDATA �́A2�����x�N�g���ł��BXDATA �̗v
% �f�́AB �̍ŏ��̗�ƍŌ�̗�� x ���W���w�肵�܂��BYDATA �̗v�f�́AB 
% �̍ŏ��̍s�ƍŌ�̍s�� y ���W���w�肵�܂��B�ʏ�AIMTRANSFORM �́A�C��
% �[�W A ��ϊ��������̂� B �����ׂĊ܂ނ悤�ɁAXDATA �� YDATA �������I
% �Ɍv�Z���܂��B�������A���Ɏ����悤�ɁA���̎����I�Ȍv�Z�����������ꍇ
% ������܂��B
%
% [B,XDATA,YDATA] = IMTRANSFORM(...,PARAM1,VAL1,PARAM2,VAL2,...) �́A��
% �ԓI�ȕϊ��̎�X�̖ʂ��R���g���[������p�����[�^��ݒ肵�܂��B�p����
% �[�^���́A�ȗ����邱�Ƃ��ł��A�啶���A�������̋�ʂ��s���܂���B
%
% �p�����[�^�ɂ́A���̂��̂��܂܂�܂��B
%
%   'UData'      2�v�f�̎����x�N�g��
%   'VData'      2�v�f�̎����x�N�g��
%                'UData' �� 'VData' �́A2�����̓��͋�� U-V �̒��̃C��
%                �[�W A �̋�ԓI�Ȉʒu���w�肵�܂��B'UData'��2�v�f�́A
%                A �̍ŏ��̗�ƍŌ�̗�� u ���W(��������)���w�肵�܂��B
%                'VData' ��2�v�f�́AA �̍ŏ��̍s�ƍŌ�̍s�� v ���W(��
%                ������)���w�肵�܂��B
%
%                'UData' �� 'VData' �̃f�t�H���g�l�́A[1 size(A,2)] �� 
%                [1 size(A,1)] �ł��B
%
%   'XData'      2�v�f�̎����x�N�g��
%   'YData'      2�v�f�̎����x�N�g��
%                'XData' �� 'YData' �́A2�����o�͋�� X-Y �̒��̏o�̓C��
%                �[�W B �̋�ԓI�Ȉʒu���w�肵�܂��B'XData' ��2�̗v�f
%                �́AB �̍ŏ��̗�ƍŌ�̗�� x ���W(��������)���w�肵��
%                ���B'YData' �̗v�f�́AB �̍ŏ��̍s�ƍŌ�̍s�� y ���W
%                (��������)���w�肵�܂��B
%
%                'XData' �� 'YData' ���ݒ肳��Ă��Ȃ��ꍇ�AIMTRANSFORM 
%                �́A�ϊ����ꂽ�o�̓C���[�W�S�̂��܂ނ悤�ɁA�����I�Ɍv
%                �Z����܂��B
%
%   'XYScale'    1�A�܂��́A2�v�f�̎����x�N�g��
%                'XYScale' �̍ŏ��̗v�f�́AX-Y ��Ԃł̊e�o�̓s�N�Z����
%                ����ݒ肵�܂��B(���݂����)2�Ԗڂ̗v�f�́A�e�o�̓s�N�Z
%                ���̍�����ݒ肵�܂��B'XYScale' ���A1�v�f�݂̂̏ꍇ�A��
%                ���l���A���ƍ����Ɏg���܂��B
%
%                'XYScale' ���A�ݒ肳��Ă��Ȃ��A'Size' ���ݒ肳��Ă���
%                �ꍇ�A'XYScale' �́A'Size', 'XData', 'YData' ����v�Z����
%                �܂��B'XYScale'��'Size' ���ݒ肳��Ă��Ȃ��ꍇ�A���̓s�N
%                �Z���̃X�P�[���́A'XYScale' �p�Ɏg���܂��B
%
%   'Size'       �񕉂̐�������\�������2�v�f�x�N�g��
%                'Size' �́A�o�̓C���[�W B �̍s���Ɨ񐔂�ݒ肵�܂��B��
%                �����̏ꍇ�AB �̃T�C�Y�́AA �̃T�C�Y���璼�ڈ����o����
%                �܂��B����������΁Asize(B,k) �́Ak>2 �̏ꍇ�Asize(A,k) 
%                �Ɠ����ł��B
%                
%                'Size' ���ݒ肳��Ă��Ȃ��ꍇ�A'XData', 'YData', 'XYScale'
%                 ����v�Z����܂��B
%
%   'FillValues' 1�܂��́A�������̃t���l���܂񂾔z��B
%                �t���l�́A���̓C���[�W�ƑΉ�����ϊ����ꂽ�ʒu���A����
%                �C���[�W���E�̊O�Ɋ��S�Ɉړ�����ꍇ�ɁA�o�̓s�N�Z����
%                �΂��Ďg���܂��BA ��2�����̏ꍇ�A'FillValues' �́A�X
%                �J���ł��B�������AA �̎����́A2��荂���Ȃ�ꍇ�A'Fill-
%                Values' �́A���̐���𖞑�����z��̃T�C�Y�ɂȂ�܂��B
%                size(fill_values,k) �́Asize(A,k+2)�A�܂��́A1�Ɠ�����
%                �Ȃ�܂��B���Ƃ��΁AA ���A200 x 200 x 3 �� uint8 �� RGB 
%                �C���[�W�̏ꍇ�A'FillValues' �ɑ΂��ĉ\�Ȓl�́A����
%                ���̂ł��B
%
%                    0                 - �t���l�t��
%                    [0;0;0]           - �t���l�t��
%                    255               - �t���l�t��
%                    [255;255;255]     - �t���l�t��
%                    [0;0;255]         - �t���l�t��
%                    [255;255;0]       - �t���l�t��
%
%                A ���A�T�C�Y 200 x 200 x 3 x 10 �� 4 �����z��̏ꍇ�A
%                'FillValues' �́A1�~10, 3�~1, 3�~10 �̃X�J����
%                �Ȃ�܂��B
%
% ����
% -----
%   - 'XData' �� 'YData' ���g���āAB �ɑ΂���o�͋�Ԃ̈ʒu���w�肵�Ă�
%     �Ȃ��ꍇ�AIMTRANSFORM �́A�֐� FINDBOUNDS ���g���āA�����I�Ɍv�Z
%     ���܂��B�������̈�ʓI�Ɏg����ϊ��A�A�t�B���ϊ���ˉe�ϊ���
%     �΂��āA�t�H���[�h�}�b�s���O�͌v�Z���e�ՂŁAFINDBOUND �͍����ɂ�
%     ��܂��B�t�H���[�h�}�b�s���O���s��Ȃ��ϊ��A���Ƃ��΁ACP2TFORM 
%     �ɂ���Čv�Z����鑽�����ϊ��ɑ΂��āAFINDBOUNDS �́A���Ȃ�̎���
%     ��v���܂��B���̂悤�ȕϊ��ɁA'XData' �� 'YData' �𒼐ڐݒ�ł���
%     �ꍇ�AIMTRANSFORM �́A���Ȃ荂���ɂȂ�܂��B
%
%   - FINDBOUNDS ���g�����A'XData' �� 'YData' �̎����I�ȎZ�o�́A�ϊ���
%     �ꂽ���̓C���[�W�̂��ׂẴs�N�Z�������S�Ɋ܂ނ��Ƃ��A���ׂẴN
%     ���X�ŕۏ؂���Ă��܂���B
%
%   - �o�͒l XDATA �� YDATA �́A���� 'XData �� 'YData' �p�����[�^�ƌ�
%     ���ɂ͈�v���܂���B����́A�����A�܂��́A�s�Ɨ�A�܂��́A'XData',
%    'YData', 'XYScale', 'Size' ���A���������ۂ���Ă��Ȃ����A�̂�����
%     ���Ɍ������Ă��܂��B�����ꂩ�̏ꍇ�AXDATA �� YDATA �̍ŏ��̗v�f
%     �́A'XData' �� 'YData' �̍ŏ��̗v�f�ƁA�e�X�A�K���������Ȃ�܂��B
%     XDATA �� YDATA ��2�Ԗڂ̗v�f�������A�قȂ�\��������܂��B
%
%   - IMTRANSFORM �́A�ϊ� TFORM �ɑ΂��āA��ԍ��W�̕\���ł��B���ɁA��
%     ���̍ŏ��̎����́A���������A�܂��́Ax ���W�ŁA2�Ԗڂ̎����́A����
%     �����A�܂��́Ay ���W�ł��B����́AMATLAB �z��̃T�u�X�N���v�e���O
%     �ł̕��@�Ƌt�ł��邱�Ƃɒ��ӂ��Ă��������B
%
%   - TFORM �́AIMTRANSFORM �Ƌ��Ɏg����2�����ϊ��ł��B�C�ӂ̎����z��
%     �̕ϊ��Ɋւ��ẮATFORMARRAY ���Q�Ƃ��Ă��������B
%
% �N���X�T�|�[�g
% -------------
% A �́A�C�ӂ̔�X�p�[�X���l�N���X�ŁA�����A�܂��́A���f���ł��BA �́A
% logical �ɂȂ邱�Ƃ��ł��܂��BB �̃N���X�́AA �̃N���X�Ɠ����ł��B
%
% ��� 1
%   --------
% ���x�C���[�W�ɐ����I�ȃY����K�p���܂��B
%
%       I = imread('cameraman.tif');
%       tform = maketform('affine',[1 0 0; .5 1 0; 0 0 1]);
%       J = imtransform(I,tform);
%       imshow(I), figure, imshow(J)
%
% ��� 2
%   --------
% �ˉe�ϊ��́A�����`���l�ӌ`�Ƀ}�b�s���O���܂��B���̗��ŁA���͍��W�n
% ����̓C���[�W���P�ʐ����`�𖞂����悤�ɐݒ肵�A���̌�A���_ (0 0), 
% (1 0), (1 1), (0 1) �����l�ӌ`���A���_  (-4 2), (-8 -3), (-3 -5), 
% (6 3) �����l�ӌ`�ɕϊ����܂��B�O���[���g���āA�t����Ƃ��s���A�o�L��
% �[�r�b�N��Ԃ��g�p���Ă��܂��B�o�͂̑傫���́A���͂̑傫���Ɠ����ɂ���
% ���܂��B
%
%       I = imread('cameraman.tif');
%       udata = [0 1];  vdata = [0 1];  % ���͂̍��W�n
%       tform = maketform('projective',[ 0 0;  1  0;  1  1; 0 1],...
%                                      [-4 2; -8 -3; -3 -5; 6 3]);
%       [B,xdata,ydata] = imtransform(I,tform,'bicubic','udata',udata,...
%                                                       'vdata',vdata,...
%                                                       'size',size(I),...
%                                                       'fill',128);
%       subplot(1,2,1), imshow(udata,vdata,I), axis on
%       subplot(1,2,2), imshow(xdata,ydata,B), axis on
%
% ��� 3
%   --------
% �q��@�̎ʐ^��orthophoto�ɕ\�����܂��B
%  
%       unregistered = imread('westconcordaerial.png');
%       figure, imshow(unregistered)
%       figure, imshow('westconcordorthophoto.png')
%       load westconcordpoints % load some points that were already picked     
%       t_concord = cp2tform(input_points,base_points,'projective');
%       info = imfinfo('westconcordorthophoto.png');
%       registered = imtransform(unregistered,t_concord,...
%                                'XData',[1 info.Width], 'YData',[1 info.Height]);
%       figure, imshow(registered)           
%
% �Q�l�F CP2TFORM, IMRESIZE, IMROTATE, MAKETFORM, MAKERESAMPLER, TFORMARRAY.



%   Copyright 1993-2002 The MathWorks, Inc.
