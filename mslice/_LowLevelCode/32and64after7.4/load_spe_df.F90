!====================================================================   
!     >> mex load_spe_df.f    
!     This is a MEX-file for MATLAB   
!     to load an ASCII spe file produced by homer/2d on ISIS alpha VMS cluster
!     07-Oct-2000 compiled for PC/WINNT using Matlab 5.3 and
!     Digital Visual Fortran Professional Edition 6
!    
!    $Revisison: $  ($Date$)
!  
!====================================================================	
subroutine mexFunction(nlhs, plhs, nrhs, prhs)
  implicit NONE
! declares the pointer and integer sizes for current os and platform
#include "fintrf.h"
  character*(40) :: PROG_NAME= 'Fortran SPE in mslice (load_spe_df.F90) '
  character*(70) :: PROG_REV = '$Rev::      $ ($Date::                                              $)'C
  character*(110):: REVISION

  
  mwpointer :: plhs(*), prhs(*)
  integer*4 :: nrhs, nlhs
  
  ! declare pointers to output variables  
  mwpointer:: data_S_pr, data_ERR_pr, data_en_pr,mfp
  mwpointer:: mxGetPr,mxCreateCharMatrixFromStrings,mxCreateDoubleMatrix
  ! declare external calling functions
  mwsize :: mxGetM, mxGetN,mxIsChar,mxGetString,one
#ifdef OBSOLETE
  integer mxCreateFull
#endif

  ! declare local operating variables of the interface funnction
  mwsize  :: ndet, ne,longOne
  integer strlen, status
  character*1024 filename

   ! Returns code SVN version
  if(nrhs==0 .AND. nlhs==1)then
        one=1
        REVISION =  PROG_NAME//PROG_REV
        plhs(1) = mxCreateCharMatrixFromStrings(one,REVISION)
        return
  end if
  longOne=1
  
  ! put in that clever interface 
  !     Check for proper number of MATLAB input and output arguments 
  if (nrhs .ne. 1) then
     write(*,*)nrhs,nlhs
     call mexErrMsgTxt('One input <filename> required.')
  elseif (nlhs .ne. 3) then
     write(*,*)nlhs
     call mexErrMsgTxt ('Three outputs (data_S,data_ERR,data_en) required.')
  elseif (mxIsChar(prhs(1)) .ne. 1) then
     call mexErrMsgTxt('Input <filename> must be a string.')
  elseif (mxGetM(prhs(1)).ne.1) then
     call mexErrMsgTxt('Input <filename> must be a row vector.')
  end if

  !     Get the length of the input string
  strlen=mxGetN(prhs(1))
  if (strlen .gt. 1024) then 
     call mexErrMsgTxt ('Input <filename> must be less than 1024 chars long.')
  end if

  !     Get the string contents
  status=mxGetString(prhs(1),filename,strlen)
  if (status .ne. 0) then 
     call mexErrMsgTxt ('Error reading <filename> string.')
  end if

  !     Read ndet and ne values 
  call load_spe_header(ndet,ne,filename)
  if (ndet .lt. 1) then
     call mexErrMsgTxt  ('File not found or error encountered during reading.')
  end if

  !     Create matrices for the return arguments, double precision real*8
#ifdef OBSOLETE
      plhs(1)=mxCreateFull(ndet,ne,0)
      plhs(2)=mxCreateFull(ndet,ne,0)
      plhs(3)=mxCreateFull(1,ne,0)            
#else
      plhs(1)=mxCreateDoubleMatrix(ndet,ne,0)
      plhs(2)=mxCreateDoubleMatrix(ndet,ne,0)
      plhs(3)=mxCreateDoubleMatrix(longOne,ne,0)                  
#endif      
  
  data_S_pr  =mxGetPr(plhs(1))
  if(data_S_pr==0) then
     call mexErrMsgTxt  ('can not obtain pointer to signal matrix') 
  end if
  data_ERR_pr=mxGetPr(plhs(2))
  if(data_ERR_pr==0) then
     call mexErrMsgTxt  ('can not obtain pointer to error matrix') 
  end if
  data_en_pr =mxGetPr(plhs(3))
  if(data_en_pr==0) then
     call mexErrMsgTxt  ('can not obtain pointer to bin sizes') 
  end if
  

  !     Call load_spe routine, pass pointers
  call load_spe(ndet,ne,%val(data_S_pr),%val(data_ERR_pr),%val(data_en_pr),filename)

  if (ndet .lt. 1) then
     call mexErrMsgTxt('Error encountered during reading the spe file.')
  end if

  return
end subroutine mexFunction

! ========================================================
! Read header of spe file, get number of detectors(ndet) 
! and number of energy bins (ne)
subroutine load_spe_header(ndet,ne,filename)
  implicit NONE
  mwsize:: ndet,ne
  character filename*(*)
  open(unit=1,STATUS='OLD',file=filename)
  read(1,*) ndet,ne 
  close(unit=1)  
  return  
999 ndet=0
  close(unit=1)
  return 
end subroutine load_spe_header

!=========================================================
! Read spe data 
subroutine load_spe(ndet,ne,data_S,data_ERR, data_en,filename)
  implicit NONE      
  mwsize :: ndet, ne
  mwsize :: idet,ien
  !     Define pointers to arrays
  real*8 data_S(*),data_ERR(*),en(ne+1), data_en(*),dum(ndet+1)
  character filename*(*)
  ! Skip over the first two lines with ndet, ne and some text ###        
  open(unit=1,file=filename)
  read(1,*) dum(1),dum(2)
  !     print*, dum(1),dum(2)
  read(1,*)
  ! angles (not used)
  read(1,'(8F10.0)') (dum(idet),idet=1,ndet+1)
  read(1,*)
  ! energy bins
  read(1,'(8F10.0)') (en(ien),ien=1,ne+1)    
  ! read intensities + errors
  do idet=1,ndet
     read(1,*)
     read(1,'(8F10.0)') (data_S(idet+ndet*(ien-1)),ien=1,ne)
     read(1,*)
     read(1,'(8F10.0)')(data_ERR(idet+ndet*(ien-1)),ien=1,ne)
  enddo
  ! calculate centres of energy bins      
  do ien=1,ne
     data_en(ien)=(en(ien)+en(ien+1))/2.0d0
  enddo
  close(unit=1)
  return
  ! 999  ndet=0    ! convention for error reading file
  close(unit=1)
  return
end subroutine load_spe

