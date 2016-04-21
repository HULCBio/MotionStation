% Image Processing Toolbox --- �f���ƃT���v���C���[�W
%                              
% �f��
%   dctdemo      - 2-D DCT �ɂ��C���[�W�̈��k�̃f��
%   edgedemo     - �G�b�W�̌��o�̃f��
%   firdemo      - 2-D FIR �t�B���^�̐݌v�ƓK�p�̃f��
%   imadjdemo    - ���x�C���[�W�̒����ƃq�X�g�O�����̋ϓ����̃f��
%   landsatdemo  - �����h�T�b�g�J���[�����̃f��
%   nrfiltdemo   - �t�B���^���g�����m�C�Y�ጸ�̃f��
%   qtdemo       - 4�����c���[�����̃f��
%   roidemo      - �Ώۗ̈�݂̂̏������s���f��
%
% �g�����ꂽ���
% ipexindex        - �g�����ꂽ���̃C���f�b�N�X
% ipexsegmicro     - ���׍\�������o���邽�߂̃Z�O�����g��
% ipexsegcell      - �זE���o�̂��߂̃Z�O�����g��
% ipexsegwatershed - Watershed �Z�O�����g��
% ipexgranulometry - ���̑傫���̕��z
% ipexdeconvwnr    - Wiener �t�B���^�ɂ�閾�ĉ�
% ipexdeconvreg    - �������ɂ�閾�ĉ�
% ipexdeconvlucy   - Lucy-Richardson�@�ɂ�閾�ĉ�
% ipexdeconvblind  - Blind deconnvolution�ɂ�閾�ĉ�
% ipextform        - �C���[�W�ϊ��M������
% ipexshear        - �C���[�W�̕t���Ƌ��L
% ipexmri          - 3-D MRI �X���C�X
% ipexconformal    - ���p�ʑ� 
% ipexnormxcorr2   - ���K���������ݑ���
% ipexrotate       - ��]�ƃX�P�[���̉�
% ipexregaerial    - �q��ʐ^�̃��W�X�g���[�V����
%
% �g���������ł̕⏕ M-�t�@�C��
%   ipex001          - �C���[�W�̕t���Ƌ��L�̗��Ŏg�p      
%   ipex002          - �C���[�W�̕t���Ƌ��L�̗��Ŏg�p      
%   ipex003          - MRI �X���C�X�̗��Ŏg�p
%   ipex004          - ���p�ˉe�̗��Ŏg�p
%   ipex005          - ���p�ˉe�̗��Ŏg�p 
%   ipex006          - ���p�ˉe�̗��Ŏg�p
%
% �T���v��MAT�t�@�C��
%   imdemos.mat           - �f���Ŏg�p����C���[�W
%   trees.mat             - ���i�}�̃C���[�W
%   westconcordpoints.mat - �q��ʐ^�ɂ�郌�W�X�g���[�V�����̗��Ŏg�p
%
% �T���v���� JPEG �C���[�W
%   football.jpg
%   greens.jpg
%
% �T���v���� PNG �C���[�W
%   concordorthophoto.png
%   concordaerial.png
%   westconcordorthophoto.png
%   westconcordaerial.png
%
% �T���v��TIFF�C���[�W
%   afmsurf.tif
%   alumgrns.tif
%   autumn.tif  
%   bacteria.tif
%   blood1.tif  
%   board.tif
%   bonemarr.tif
%   cameraman.tif
%   canoe.tif   
%   cell.tif
%   circbw.tif
%   circles.tif 
%   circlesm.tif
%   debye1.tif  
%   eight.tif   
%   enamel.tif  
%   flowers.tif
%   forest.tif
%   ic.tif
%   kids.tif
%   lily.tif
%   logo.tif
%   m83.tif
%   moon.tif
%   mri.tif
%   ngc4024l.tif
%   ngc4024m.tif
%   ngc4024s.tif
%   paper1.tif
%   pearlite.tif
%   pout.tif
%   rice.tif
%   saturn.tif
%   shadow.tif
%   shot1.tif
%   spine.tif
%   testpat1.tif
%   testpat2.tif
%   text.tif
%   tire.tif
%   tissue1.tif
%   trees.tif
%
% �T���v���̃����h�T�b�g�C���[�W
%   littlecoriver.lan
%   mississippi.lan
%   montana.lan
%   paris.lan
%   rio.lan
%   tokyo.lan
%
% Photo credits
%   afmsurf, alumgrns, bacteria, blood1, bonemarr, circles, circlesm,
%   debye1, enamel, flowers, ic, lily, ngc4024l, ngc4024m, ngc4024s,
%   pearlite, rice, saturn, shot1, testpat1, testpat2, text, tire, tissue1:
%
%     Copyright J. C. Russ, The Image Processing Handbook, 
%     Third Edition, 1998, CRC Press, Boca Raton, ISBN
%     0-8493-2532-3.  Used with permission.
%
%   moon:
%
%     Copyright Michael Myers.  Used with permission.
%
%   cameraman:
%
%     Copyright Massachusetts Institute of Technology.  Used with
%     permission.
%
%   trees:
%
%     Trees with a View, watercolor and ink on paper, copyright Susan
%     Cohen.  Used with permission. 
%
%   forest:
%
%     Photograph of Carmanah Ancient Forest, British Columbia, Canada,
%     courtesy of Susan Cohen. 
%
%   circuit:
%
%     Micrograph of 16-bit A/D converter circuit, courtesy of Steve
%     Decker and Shujaat Nadeem, MIT, 1993. 
%
%   m83:
%
%     M83 spiral galaxy astronomical image courtesy of Anglo-Australian
%     Observatory, photography by David Malin. 
%
%   cell:
%
%     Cancer cell from a rat's prostate, courtesy of Alan W. Partin, M.D,
%     Ph.D., Johns Hopkins University School of Medicine.
%
%   board:
%
%     Computer circuit board, courtesy of Alexander V. Panasyuk,
%     Ph.D., Harvard-Smithsonian Center for Astrophysics.
%
%   LAN files:
%
%     Permission to use Landsat TM data sets provided by Space Imaging,
%     LLC, Denver, Colorado.
%
%   concordorthophoto and westconcordorthophoto:
%
%     Orthoregistered photographs courtesy of Massachusetts Executive Office
%     of Environmental Affairs, MassGIS.
%
%   concordaerial and westconcordaerial:
%
%     Visible color aerial photographs courtesy of mPower3/Emerge.



%   Copyright 1993-2002 The MathWorks, Inc.  
