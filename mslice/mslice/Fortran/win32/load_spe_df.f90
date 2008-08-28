!====================================================================   
!     >> mex load_spe_df.f    
!     This is a MEX-file for MATLAB   
!     to load an AS!II spe file produced by homer/2d on ISIS alpha VMS cluster
!     07-Oct-2000 compiled for PC/WINNT using Matlab 5.3 and
!     Digital Visual Fortran Professional Edition 6
!====================================================================	
subroutine mexFunction(nlhs, plhs, nrhs, prhs)
  !--------------------------------------------------------------------
  !     (integer) Replace integer by integer*8 on the DEC Alpha and the
  !     SGI 64-bit platforms
  implicit NONE
  ! declare input/output variables of the mexFunction
  integer*4 plhs(*), prhs(*)
  integer*4 nrhs, nlhs
  ! declare pointers to output variables  
  integer*4,pointer:: data_S_pr, data_ERR_pr, data_en_pr
  ! declare external calling functions
  integer*4  mxGetString,mxCreateFull, mxGetM, mxIsString,  mxGetN !, mxGetPr

  ! declare local operating variables of the interface funnction
  integer*4 ndet, ne, strlen, status
  character*120 filename
  ! put in that clever interface 
  interface
     function mxgetpr(pm)
       integer*4,pointer :: mxgetpr
       integer*4 :: pm
     end function mxgetpr
  end interface

  !     Check for proper number of MATLAB input and output arguments 
  if (nrhs .ne. 1) then
     write(*,*)nrhs,nlhs
     call mexErrMsgTxt('One input <filename> required.')
  elseif (nlhs .ne. 3) then
     write(*,*)nlhs
     call mexErrMsgTxt ('Three outputs (data_S,data_ERR,data_en) required.')
  elseif (mxIsString(prhs(1)) .ne. 1) then
     call mexErrMsgTxt('Input <filename> must be a string.')
  elseif (mxGetM(prhs(1)).ne.1) then
     call mexErrMsgTxt('Input <filename> must be a row vector.')
  end if

  !     Get the length of the input string
  strlen=mxGetN(prhs(1))
  if (strlen .gt. 120) then 
     call mexErrMsgTxt ('Input <filename> must be less than 120 chars long.')
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
  plhs(1)=mxCreateFull(ndet,ne,0)
  data_S_pr=>mxGetPr(plhs(1))
  plhs(2)=mxCreateFull(ndet,ne,0)      
  data_ERR_pr=>mxGetPr(plhs(2))
  plhs(3)=mxCreateFull(1,ne,0)      
  data_en_pr=>mxGetPr(plhs(3))

  !     Call load_spe routine, pass pointers
  call load_spe(ndet,ne,data_S_pr,data_ERR_pr,data_en_pr,filename)

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
  integer*4 ndet,ne
  character filename*120
  open(unit=1,file=filename)
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
  integer*4 ndet,ne,idet,ien
  !     Define pointers to arrays
  real*8 data_S(*),data_ERR(*),en(ne+1), data_en(*),dum(ndet+1)
  character filename*120
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

