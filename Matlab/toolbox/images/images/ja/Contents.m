% Image Processing Toolbox.
% Version 3.2 (R13) 28-Jun-2002
%
% �����[�X���
% images/Readme    - �J�����g�o�[�W�����ƑO�̃o�[�W�����Ɋւ������\��
%
% �C���[�W�\��
% colorbar         - �J���[�o�[�̕\��(MATLAB ��{���W���[���Ɋ܂܂�܂�)
% getimage         - ������C���[�W�f�[�^���擾
% image            - �C���[�W�I�u�W�F�N�g�̍쐬�ƕ\��(MATLAB ��{���W���[����
%                    �܂܂�܂�)
% imagesc          - �f�[�^���X�P�[�����O���A�C���[�W�Ƃ��ĕ\��(MATLAB ��{��
%                    �W���[���Ɋ܂܂�܂�)
% immovie          - �}���`�t���[���C���f�b�N�X�t���C���[�W���烀�[�r�[�̍쐬
% imshow           - �C���[�W�̕\��
% montage          - �����̃C���[�W�t���[������̒����`�����^�[�W���Ƃ��ĕ\
%                    ��
% movie            - �L�^���ꂽ���[�r�B�t���[����\��(MATLAB ��{���W���[����
%                    �܂܂�܂�)
% subimage         - �����C���[�W��P��� figure �ɕ\��
% truesize         - �C���[�W�̕\���T�C�Y�̒���
% warp             - �C���[�W���e�N�X�`���[�}�b�v�T�[�t�F�X�ɕ\��
%
% �C���[�W�t�@�C���̓��o��
% dicominfo        - DICOM ���b�Z�[�W���烁�^�f�[�^��ǂݍ���
% dicomread        - DICOM �C���[�W��ǂݍ���
% dicomwrite       - DICOM �C���[�W����������
% dicom-dict.txt   - DICOM �f�[�^�f�B�N�V���i���[���܂ރe�L�X�g�t�@�C��
% imfinfo          - �C���[�W�t�@�C���̏��̎擾(MATLAB ��{���W���[���Ɋ܂�
%                    ��܂�)
% imread           - �C���[�W�t�@�C���̓ǂݍ���(MATLAB ��{���W���[���Ɋ܂܂�
%                    �܂�)
% imwrite          - �C���[�W�t�@�C���̏����o��(MATLAB ��{���W���[���Ɋ܂܂�
%                    �܂�)
%
% �C���[�W�Z�p
% imabsdiff        - 2�̃C���[�W�̍��̐�Βl���v�Z
% imadd            - 2�̃C���[�W�̉��Z�A�܂��́A�萔���C���[�W�ɉ��Z
% imcomplement     - �C���[�W�̕�W��
% imdivide         - 2�̃C���[�W�̏��Z�A�܂��́A�C���[�W��萔�ŏ��Z
% imlincomb        - �C���[�W�̐��`�������v�Z
% immultiply       - 2�̃C���[�W�̏�Z�A�܂��́A�C���[�W�ƒ萔�̏�Z
% imsubtract       - 2�̃C���[�W�̌��Z�A�܂��́A�C���[�W����萔�̌��Z
%
% �􉽊w�I�ϊ�
% checkerboard     - �`�F�b�N�{�[�h�C���[�W�̍쐬
% findbounds       - �􉽊w�I�ϊ��ɑ΂���o�͔͈͂̌��o
% fliptform        - �\���� TFORM �̓��͂Əo�͂̔��]
% imcrop           - �C���[�W�̒��o
% imresize         - �C���[�W�̃��T�C�Y
% imrotate         - �C���[�W�̉�]
% imtransform      - �􉽊w�I�ϊ����C���[�W�ɓK�p
% makeresampler    - resampler �\���̂̍쐬
% maketform        - �􉽊w�I�ϊ��\����(TFORM)�̍쐬
% tformarray       - �􉽊w�I�ϊ��� N-�����z��ɓK�p
% tformfwd         - �t�H���[�h�􉽊w�I�ϊ���K�p
% tforminv         - �t�􉽊w�I�ϊ���K�p
%
% �C���[�W���W�X�g���[�V����
% cpstruct2pairs   - CPSTRUCT ���R���g���[���|�C���g�̐������g�ɕϊ�
% cp2tform         - �R���g���[���|�C���g�̑g����􉽊w�I�ϊ��𐄒�
% cpcorr           - ���ݑ��ւ��g���āA�R���g���[���|�C���g�̈ʒu�𒲐�
% cpselect         - �R���g���[���|�C���g�̑I���c�[��
% normxcorr2       - ���K������2�����̑��ݑ���
%
% �s�N�Z���l�Ɠ��v
% corr2            - 2�������֌W���̌v�Z
% imcontour        - �C���[�W�f�[�^�R���^�[�v���b�g�̍쐬
% imhist           - �C���[�W�f�[�^�̃q�X�g�O�����̕\��
% impixel          - �s�N�Z���J���[�l�̌���
% improfile        - ���C���Z�O�����g�ɉ������s�N�Z���l�̒f�ʐ}�̌v�Z
% mean2            - �s��v�f�̕��ϒl�̌v�Z
% pixval           - �C���[�W�s�N�Z�����̕\��
% regionprops      - �C���[�W�̈�̃v���p�e�B�̑���
% std2             - �s��v�f�̕W���΍��̌v�Z
%
% �C���[�W�̉��
% edge             - ���x�C���[�W�ł̃G�b�W�̌��o
% qtdecomp         - 4�����c���[����
% qtgetblk         - 4�����c���[�����ł̃u���b�N�l�̎擾
% qtsetblk         - 4�����c���[�����ł̃u���b�N�l�̐ݒ�
%
% �C���[�W�̋���
% histeq           - �q�X�g�O�����̋ϓ������g���āA�R���g���X�g�̋���
% imadjust         - �C���[�W�̋��x�l�A�܂��́A�J���[�}�b�v�̒���
% imnoise          - �m�C�Y���C���[�W�ɕt��
% medfilt2         - 2�������f�B�A���t�B���^����
% ordfilt2         - 2�����̏��ʕt�����ꂽ���v�I�ȃt�B���^����
% stretchlim       - �C���[�W�̃R���g���X�g��傫�����鋫�E�̌��o
% wiener2          - 2�����K���m�C�Y�����t�B���^����
%
% ���`�t�B���^�����O
% convmtx2         - 2�����R���{�����[�V�����s��̌v�Z
% fspecial         - ���[�U��`�̃t�B���^�̍쐬
% imfilter         - 2�����AN �����̃t�B���^
%
% ���`2�����t�B���^�݌v
% freqspace        - 2�������g���������v�Z������g���_�̌���(MATLAB ��{���W��
%                    �[���Ɋ܂܂�܂�)
% freqz2           - 2�������g�������̌v�Z
% fsamp2           - ���g���T���v���@���g����2���� FIR �t�B���^�̐݌v
% ftrans2          - ���g���ϊ��@���g����2���� FIR �t�B���^�̐݌v
% fwind1           - 1�����E�B���h�E�@���g����2���� FIR �t�B���^�̐݌v
% fwind2           - 2�����E�B���h�E�@���g����2���� FIR �t�B���^�̐݌v
%
% �C���[�W�̖��ĉ� 
% deconvblind      - Blind �f�R���{�����[�V�������g�����s���ăC���[�W��
% �@�@�@�@�@�@�@�@�@ ���ĉ�
% deconvlucy       - Lucy-Richardson �@���g���āA�C���[�W�̖��ĉ�
% deconvreg        - �������t�B���^���g���āA�C���[�W�̖��ĉ�
% deconvwnr        - Wiener �t�B���^���g���āA�C���[�W�̖��ĉ�
% edgetaper        - �_�����x�֐����g���āA�G�b�W�Ƀe�[�p��K�p
% otf2psf          - ���w�I�`�B�֐���_�����x�֐��ɕϊ�
% psf2otf          - �_�����x�֐������w�I�`�B�֐��ɕϊ�
%
% �C���[�W�ϊ�
% dct2             - 2�������U�R�T�C���ϊ�
% dctmtx           - ���U�R�T�C���ϊ��s��̌v�Z
% fft2             - 2���������t�[���G�ϊ�(MATLAB ��{���W���[���Ɋ܂܂�܂�)
% fftn             - N ���������t�[���G�ϊ�(MATLAB ��{���W���[���Ɋ܂܂�܂�)
% fftshift         - FFT �̏o�͌��ʂ̕��בւ�(MATLAB ��{���W���[���Ɋ܂܂��
%                    ��)
% idct2            - 2�����t���U�R�T�C���ϊ�
% ifft2            - 2���������t�t�[���G�ϊ�(MATLAB ��{���W���[���Ɋ܂܂�܂�)
% ifftn            - N ���������t�t�[���G�ϊ�(MATLAB ��{���W���[���Ɋ܂܂�܂�)
% iradon           - �t���h���ϊ�
% phantom          - �w�b�h�t�@���g���C���[�W�̍쐬
% radon            - ���h���ϊ�
%
% �ߖT�����ƃu���b�N����
% bestblk          - �u���b�N�����p�̃u���b�N�T�C�Y�̑I��
% blkproc          - �C���[�W�Ƀu���b�N������K�p
% col2im           - �s�����u���b�N�ɕ��ёւ�
% colfilt          - ��K�p�֐����g���āA�ߖT������K�p
% im2col           - �C���[�W�u���b�N���ɕ��ёւ�
% nlfilter         - ��ʓI�ȃX���C�f�B���O�ߖT��������s
%
% �`�Ԋw�I���� (���x�C���[�W�ƃo�C�i���C���[�W)
% conndef          - �f�t�H���g�̌����z��
% imbothat         - bottom-hat �t�B���^����̎���
% imclearborder    - �C���[�W�̋��E�ɐڑ����Ă��閾�邢�\���̗}��
% imclose          - �C���[�W�̃N���[�Y����
% imdilate         - �C���[�W�̖c��
% imerode          - �C���[�W�̏k��
% imextendedmax    - Extended-maxima �ϊ�
% imextendedmin    - Extended-minima �ϊ�
% imfill           - �C���[�W�̈��z�[���̓h��ׂ�
% imhmax           - H-maxima �ϊ�
% imhmin           - H-minima �ϊ�
% imimposemin      - �ŏ��l�̊��蓖��
% imopen           - �C���[�W�̃I�[�v������
% imreconstruct    - �`�Ԋw�I�č\��
% imregionalmax    - �n��I�ȍő�l�̏W�܂�
% imregionalmin    - �n��I�ȍŏ��l�̏W�܂�
% imtophat         - tophat �t�B���^����̎���
% watershed        - Watershed �ϊ�
%
% �`�Ԋw�I���� (�o�C�i���C���[�W)
% applylut         - ���b�N�A�b�v�e�[�u�����g���āA�ߖT��������s
% bwarea           - �o�C�i���C���[�W���̃I�u�W�F�N�g�̖ʐόv�Z
% bwareaopen       - �o�C�i���̈�̃I�[�v������ (�������I�u�W�F�N�g���폜)
% bwdist           - �o�C�i���C���[�W�̋����ϊ��̌v�Z
% bweuler          - �o�C�i���C���[�W�� Euler ���̌v�Z
% bwhitmiss        - �o�C�i�� hit-miss ���Z
% bwlabel          - 2�����o�C�i���C���[�W���Ō������Ă���v�f�̃��x���t��
% bwlabeln         - N-�����o�C�i���C���[�W���ŁA�������Ă���v�f�̃��x��
%                    �t��
% bwmorph          - �o�C�i���C���[�W��ł̌`�Ԋw�I����̓K�p
% bwpack           - �o�C�i���C���[�W�̃p�b�N
% bwperim          - �o�C�i���C���[�W���ł���I�u�W�F�N�g�̎��͂̌���
% bwselect         - �o�C�i���C���[�W���ŃI�u�W�F�N�g�̑I��
% bwulterode       - �ŏI�I�ȏk��
% bwunpack         - �o�C�i���C���[�W�̈��k����
% makelut          - applylut �Ŏg�p���郋�b�N�A�b�v�e�[�u���̍쐬
%
% �\�����v�f(STREL)�̍쐬�Ǝ�舵��
% getheight        - strel �����̎擾
% getneighbors     - strel �ߖT�̃I�t�Z�b�g�̈ʒu�ƍ����̎擾
% getnhood         - strel �ߖT�̎擾
% getsequence      - �������ꂽ strel �Q�̎擾
% isflat           - ���R�� strel �̌��o
% reflect          - ���S�̊ւ��āA�Ώ̂� strel �̍쐬 (180����])
% strel            - �`�Ԋw�I�ȍ\�����v�f�̍쐬
% translate        - strel �̕ϊ�
%
% �̈�P�ʂ̏���
% roicolor         - �J���[���x�[�X�ɑΏۗ̈�̑I��
% roifill          - �C�ӂ̗̈���ŁA�����ɓ��}
% roifilt2         - �Ώۗ̈�̃t�B���^����
% roipoly          - �Ώۗ̈�𑽊p�`�őI��
%
% �J���[�}�b�v����
% brighten         - �J���[�}�b�v�̖��邳�̕ύX(MATLAB ��{���W���[���Ɋ܂܂�
%                    �܂�)
% cmpermute        - �J���[���J���[�}�b�v�ɕ��ёւ�
% cmunique         - ���j�[�N�ȃJ���[�}�b�v�J���[�Ƃ���ɑΉ�����C���[�W�̌�
%                    �o
% colormap         - �J���[���b�N�A�b�v�e�[�u���̐ݒ�A�܂��́A�擾(MATLAB ��
%                    �{���W���[���Ɋ܂܂�܂�)
% imapprox         - �C���f�b�N�X�t���C���[�W�f�[�^�����Ȃ��J���[�ŋߎ�
% rgbplot          - RGB �J���[�}�b�v�v�f�̃v���b�g(MATLAB ��{���W���[���Ɋ�
%                    �܂�܂�)
%
% �J���[��Ԃ̕ϊ�
% hsv2rgb          - HSV �l�� RGB �J���[��Ԃɕϊ�(MATLAB ��{���W���[��
%                    �Ɋ܂܂�܂�)
% ntsc2rgb         - NTSC �l�� RGB �J���[��Ԃɕϊ�
% rgb2hsv          - RGB �l�� HSV �J���[��Ԃɕϊ�(MATLAB ��{���W���[��
%                    �Ɋ܂܂�܂�)
% rgb2ntsc         - RGB �l�� NTSC �J���[��Ԃɕϊ�
% rgb2ycbcr        - RGB �l�� YCBCR �J���[��Ԃɕϊ�
% ycbcr2rgb        - YCBCR �l�� RGB �J���[��Ԃɕϊ�
%
% �z�񉉎Z
% circshift        - �z�������I�ɃV�t�g(MATLAB ��{���W���[���Ɋ܂܂�܂�)
% padarray         - �z��̕t��
%
% �C���[�W�^�C�v�ƃ^�C�v�̕ϊ�
% dither           - �f�B�U�����O���g���āA�C���[�W�̕ϊ�
% gray2ind         - ���x�C���[�W����C���f�b�N�X�t���C���[�W�ɕϊ�
% grayslice        - �X���b�V���z�[���h�@���g���āA���x�C���[�W����C���f�b�N�X
%                    �t���C���[�W�ɕϊ�
% graythresh       - Otsu �@���g���āA�O���[�o���C���[�W�̃X���b�V���z�[���h��
%                    �v�Z
% im2bw            - �X���b�V���z�[���h�@���g���āA�C���[�W���o�C�i���C���[�W
%                    �ɕϊ�
% im2double        - �C���[�W�z���{���x�ɕϊ�
% im2java          - �C���[�W��Java�C���[�W�ɕϊ�(MATLAB ��{���W���[����
%                    �܂܂�܂�)
% im2uint8         - �C���[�W�z���8�r�b�g�����Ȃ������ɕϊ�
% im2uint16        - �C���[�W�z���16�r�b�g�����Ȃ������ɕϊ�
% ind2gray         - �C���f�b�N�X�t���C���[�W�����x�C���[�W�ɕϊ�
% ind2rgb          - �C���f�b�N�X�t���C���[�W�� RGB �C���[�W�ɕϊ�(MATLAB ��{
%                    ���W���[���Ɋ܂܂�܂�)
% isbw             - �o�C�i���C���[�W�̌���
% isgray           - ���x�C���[�W�̌���
% isind            - �C���f�b�N�X�t���C���[�W�̌���
% isrgb            - RGB �C���[�W�̌���
% label2rgb        - ���x�����s��� RGB �C���[�W�ɕϊ�
% mat2gray         - �s������x�C���[�W�ɕϊ�
% rgb2gray         - RGB �C���[�W�A�܂��́A�J���[�}�b�v���O���[�X�P�[���ɕϊ�
% rgb2ind          - RGB �C���[�W���C���f�b�N�X�t���C���[�W�ɕϊ�
%
% �c�[���{�b�N�X�̗D�揇��
% iptgetpref       - Image Processing Toolbox �̗D�揇�ʂ̎擾
% iptsetpref       - Image Processing Toolbox �̗D�揇�ʂ̐ݒ�
%
% �f�����X�g���[�V����
% dctdemo          - 2���� DCT �C���[�W�̈��k�Ɋւ���f��
% edgedemo         - �G�b�W�̌��o�̃f��
% firdemo          - 2���� FIR �t�B���^�݌v�Ə����̃f��
% imadjdemo        - ���x�̒����ƃq�X�g�O�����̋ϓ����̃f��
% landsatdemo      - Landsat �̃J���[�����̃f��
% nrfiltdemo       - �m�C�Y�����t�B���^����̃f��
% qtdemo           - 4���������̃f��
% roidemo          - �Ώۗ̈�݂̂̏����̓K�p�f��
%
% �X���C�h�V���[
% ipss001          - �|�S�̗��q�̗̈�̃��x�����O
% ipss002          - �����x�[�X�̘_��
% ipss003          - ��l�łȂ��Ɠx�̕␳
%
% �g���f��
% ipexindex        - �g���������̃C���f�b�N�X
% ipexsegmicro     - ���׍\�������o���邽�߂̃Z�O�����g��
% ipexsegcell      - �זE���o�̂��߂̃Z�O�����g��
% ipexsegwatershed - Watershed �Z�O�����g��
% ipexgranulometry - ���̑傫���̕��z
% ipexdeconvwnr    - Wiener �t�B���^�ɂ�閾�ĉ�
% ipexdeconvreg    - �������ɂ�閾�ĉ�
% ipexdeconvlucy   - Lucy-Richardson�@�ɂ�閾�ĉ�
% ipexdeconvblind  - Blind �f�R���{�����[�V�����ɂ�閾�ĉ�
% ipextform        - �C���[�W�ϊ��M������
% ipexshear        - �C���[�W�̕t���Ƌ��L
% ipexmri          - 3-D MRI �X���C�X
% ipexconformal    - ���p�ʑ� 
% ipexnormxcorr2   - ���K���������ݑ���
% ipexrotate       - ��]�ƃX�P�[���̉�
% ipexregaerial    - �q��ʐ^�̃��W�X�g���[�V����



%   Copyright 1993-2002 The MathWorks, Inc.
