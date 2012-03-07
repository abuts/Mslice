td=testspe.load_ms_data('fake_file',25,10);
ti=testspe.get_ms_img_powder_data(td,[1,2],1,4);
ti=calcprojpowder(ti);
testspe.ms_disp_powder(ti)