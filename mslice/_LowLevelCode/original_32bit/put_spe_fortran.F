C-----------------------------------------------------------------------
C     MEX-file for MATLAB to write an ASCII spe file
C
C     Syntax:
C     >> ierr = put_spe_fortran (filename,data_S,data_E,en)
C
C     filename            name of spe file
C     data_S(ne,ndet)     here ndet=no. detectors, ne=no. energy bins
C     data_ERR(ne,ndet)       "
C     en(ne+1,1)          energy bin boundaries
C
C     ierr                =0 all OK, =1 otherwise
C
C
C-----------------------------------------------------------------------
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
      implicit none
C declare input/output variables of the mexFunction
      integer plhs(*), prhs(*), nrhs, nlhs
C declare pointers to output variables  
      integer data_S_pr, data_ERR_pr, data_en_pr, ierr_pr
C declare external calling functions
      integer mxGetString, mxCreateDoubleMatrix, mxGetM, mxGetN, mxGetPr
      integer mxIsString, mxIsNumeric
C declare local operating variables of the interface funnction
      integer ndet, ne, strlen, status
      character*255 filename

C     Check for proper number of MATLAB input and output arguments 
      if (nrhs .ne. 4) then
          call mexErrMsgTxt('Four inputs (file,S,ERR,en) required.')
      elseif (nlhs .ne. 1) then
          call mexErrMsgTxt
     +        ('One output (ierr) required.')
      elseif (mxIsString(prhs(1)) .ne. 1) then
          call mexErrMsgTxt('Input <filename> must be a string.')
      elseif (mxGetM(prhs(1)).ne.1) then
          call mexErrMsgTxt('Input <filename> must be a row vector.')
      end if

C     Get the length of the input string
      strlen=mxGetN(prhs(1))
      if (strlen .gt. 255) then 
          call mexErrMsgTxt 
     +        ('Input <filename> must be less than 255 chars long.')
      end if 
     
C     Get the string contents
      status=mxGetString(prhs(1),filename,strlen)
      if (status .ne. 0) then 
          call mexErrMsgTxt ('Error reading <filename> string.')
      end if 

C     Check to see if the other inputs are numeric
      if (mxIsNumeric(prhs(2)) .ne. 1) then
          call mexErrMsgTxt('Input #2 is not a numeric array.')
      else if (mxIsNumeric(prhs(3)) .ne. 1) then
          call mexErrMsgTxt('Input #3 is not a numeric array.')
      else if (mxIsNumeric(prhs(4)) .ne. 1) then
          call mexErrMsgTxt('Input #4 is not a numeric array.')
      endif

C     Get ndet and ne values 
      ne=mxGetM(prhs(2))
      ndet=mxGetN(prhs(2))

C     Get pointers to input data
      data_S_pr = mxGetPr (prhs(2))
      data_ERR_pr = mxGetPr (prhs(3))
      data_en_pr = mxGetPr (prhs(4)) 

C     Create scalar for the return argument
      plhs(1)=mxCreateDoubleMatrix(1,1,0)
      ierr_pr = mxGetPr (plhs(1))

C     Call load_spe routine, pass pointers
      call write_spe(ndet,ne,%val(data_S_pr), 
     +       %val(data_ERR_pr),%val(data_en_pr),filename,%val(ierr_pr))

      return
      end
   

C-----------------------------------------------------------------------
C Write spe data 
      subroutine write_spe(ndet,ne,data_S,data_ERR,data_en,
     +                                            filename,err)
      implicit none      
      integer ndet,ne,k,idet
      double precision data_S(ne,ndet),data_ERR(ne,ndet),data_en(ne+1),
     +                 err
      character*(*) filename

      err=0.0d0
C Skip over the first two lines with ndet, ne and some text ###        
      open(unit=1,file=filename,status='REPLACE',ERR=999)
      write(1,'(2i8)',ERR=999) ndet,ne
C angles (not used)
      write (1,'(a)',ERR=999) '### Phi Grid'
      write (1,100,ERR=999) (dble(k)-0.5d0,k=1,ndet+1)
C energy bins
      write (1,'(a)',ERR=999) '### Energy Grid'
      write (1,100,ERR=999) (data_en(k),k=1,ne+1)    
C read intensities + errors
      do idet = 1, ndet
          write (1,'(a)',ERR=999) '### S(Phi,w)'
          write (1,100,ERR=999) (data_S(k,idet), k=1,ne)
          write (1,'(a)',ERR=999) '### Errors'
          write (1,100,ERR=999) (data_ERR(k,idet), k=1,ne)      
      end do
 100  format(1p,8e10.3)
      close(unit=1)
      return

 999  err=1.0d0    ! convention for error writing file
      close(unit=1)
      return
      end
