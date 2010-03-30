!===============================================================================
!     >> mex cut3dxye_df.f
!     This is a MEX-file for MATLAB.   
!     to take a 1D cut from a 3D data set of pixels with (vx,vy,vz) coordinates 
!     take only pixels with coordinate vy_min<=vy<=vy_max, vz_min<=vz<=vz_max 
!     and rebin data along vx axis [vx_min to vx_max] 
!     24-Oct-2000 version for Digital Visual Fortran 6
!     use passing pointers in Fortran through the %VAL construct
!    
!     Dickon Champion 21-Feb-2008 
!     compiled for PC (32 bit)/ Linux (32 &64 bit) file converted to fortran 90, 
!     using an interface to the matlab functions to avoid the use of the %VAL construct
!     should compile with the following compilers for linux: g95,gfortran,ifort
!===============================================================================
subroutine mexFunction(nlhs, plhs, nrhs, prhs)
  !-----------------------------------------------------------------------
  !     (integer) Replace integer by integer*8 on the DEC Alpha and the
  !     SGI 64-bit platforms
  implicit NONE
  integer,parameter :: i8b = selected_int_kind(18)
  integer*8 plhs(*), prhs(*),  temp
  integer*4 nrhs, nlhs
  !     <temp> will be temporary mxArray in place of plhs(1),plhs(2),...
  ! declare local variables to deal with pointers to variables passed by/to MATLAB
  integer*8,pointer:: vx_pr, vy_pr, vz_pr, pixel_int_pr, pixel_err_pr, grid_pr,temp_pr
  integer*8,pointer:: x_pr, intensity_pr, error_int_pr
  ! declare calling functions
  integer*8 mxCreatedoublematrix, mxGetM, mxGetN, mxIsNumeric
  ! declare local operating variables of the interface funnction
  integer*8 ndet, ne, n, m
  real*8 grid(7), vx_min, vx_max, bin_vx, vy_min, vy_max, vz_min, vz_max, vvy(1), vvz(1), eps
  interface
     function mxgetpr(pm)
       integer*8,pointer :: mxgetpr
       integer*8 :: pm
     end function mxgetpr
  end interface
  interface
     subroutine mxcopyptrtoreal8(pm,array,n)
       integer*8,pointer :: pm
       integer*8::n
       real*8:: array(n)
     end subroutine mxcopyptrtoreal8
  end interface
  interface
     subroutine mxcopyreal8toptr(array,pm,n)
       integer*8,pointer :: pm
       integer*8::n
       real*8:: array(n)
     end subroutine mxcopyreal8toptr
  end interface
  !     Check for proper number of MATLAB input and output arguments 

  if (nrhs .ne. 6) then
     call mexErrMsgTxt('Six inputs (vx,vy,vz,pixel_int,pixel_err,grid) required.')
  elseif (nlhs .ne. 5) then
     call mexErrMsgTxt('Five outputs (x,intensity,err_int,vy,vz) required.')
  end if

  !     Check to see if all inputs are numeric
  if         (mxIsNumeric(prhs(1)) .ne. 1) then
     call mexErrMsgTxt('Input #1 is not a numeric array.')
  elseif     (mxIsNumeric(prhs(2)) .ne. 1) then
     call mexErrMsgTxt('Input #2 is not a numeric array.')
  elseif     (mxIsNumeric(prhs(3)) .ne. 1) then
     call mexErrMsgTxt('Input #3 is not a numeric array.')
  elseif     (mxIsNumeric(prhs(4)) .ne. 1) then
     call mexErrMsgTxt('Input #4 is not a numeric array.')
  elseif     (mxIsNumeric(prhs(5)) .ne. 1) then
     call mexErrMsgTxt('Input #5 is not a numeric array.')
  elseif     (mxIsNumeric(prhs(6)) .ne. 1) then
     call mexErrMsgTxt('Input #6 is not a numeric array.')
  end if

  !     Check sizes of input arguments
  ndet=mxGetM(prhs(1))
  ne  =mxGetN(prhs(1))
  if     ((mxGetM(prhs(2)).ne.ndet).or.(mxGetN(prhs(2)).ne.ne)) then
     call mexErrMsgTxt('Size of input #2 does not mach that of input #1')
  elseif ((mxGetM(prhs(3)).ne.ndet).or.(mxGetN(prhs(3)).ne.ne)) then
     call mexErrMsgTxt('Size of input #3 does not mach that of input #1')
  elseif ((mxGetM(prhs(4)).ne.ndet).or.(mxGetN(prhs(4)).ne.ne)) then
     call mexErrMsgTxt('Size of input #4 does not mach that of input #1')
  elseif ((mxGetM(prhs(5)).ne.ndet).or.(mxGetN(prhs(5)).ne.ne)) then
     call mexErrMsgTxt('Size of input #5 does not mach that of input #1')
  elseif ((mxGetN(prhs(6))*mxGetM(prhs(6))) .ne. 7) then
     call mexErrMsgTxt('Input #6 grid should have 7 elements.')
  end if


  !     Check sizes of input arguments
  ndet=mxGetM(prhs(1))
  ne  =mxGetN(prhs(1)) 


  !     Get vx,vy,vz,pixel_int,pixel_err and grid parameters
  vx_pr=>mxGetPr(prhs(1))
  vy_pr=>mxGetPr(prhs(2))
  vz_pr=>mxGetPr(prhs(3)) 
  pixel_int_pr=>mxGetPr(prhs(4))
  pixel_err_pr=>mxGetPr(prhs(5))
  grid_pr=>mxGetPr(prhs(6))
  call mxCopyPtrToReal8(grid_pr,grid,7_i8b)
  vx_min=grid(1)
  vx_max=grid(2)
  bin_vx=grid(3)
  vy_min=grid(4)
  vy_max=grid(5)
  vz_min=grid(6)
  vz_max=grid(7)     
  eps=1.0d-5*(vx_max-vx_min) ! this will be a small number (0 for practical purposes) in units of vx-axis
  !     if bin_x=0 by convention do not bin data along vx axis, for each detector bin along the energy axis
  if (bin_vx .lt. eps) then  ! use binning along the energy axis for each detector 
     n=ndet ! all detectors can contribute
     ! keep vx_min and vx_max as they are
  else ! normal binnig along the vx axis
     n=int((vx_max+bin_vx-(vx_min-bin_vx/2.0d0))/bin_vx) ! total number of bins 
     ! redefine vx_min and vx_max to include -bin_vx/2 on the left and +(bin_vx/2 or bin_vx) on the right
     ! pass these numbers to the cut2d_df subroutine for faster comparisons of pixel inclusion criteria 
     vx_min=vx_min-bin_vx/2.0d0
     vx_max=vx_min+dfloat(n)*bin_vx
  end if

  !     Create matrices for the return arguments (operating workspace for the subroutine cut3dxye_df)
  plhs(1)	    =mxCreatedoublematrix(1_i8b,n,0) ! these are matlab pointers
  plhs(2)	    =mxCreatedoublematrix(1_i8b,n,0)
  plhs(3)       =mxCreatedoublematrix(1_i8b,n,0)
  x_pr          =>mxGetPr(plhs(1)) ! these are fortran pointers of the matlab mxArrays created above
  intensity_pr  =>mxGetPr(plhs(2)) 
  error_int_pr  =>mxGetPr(plhs(3))

  !     Call the computational subroutine cut3dxye_df
  call cut3dxye_df(vx_pr,vy_pr,vz_pr,pixel_int_pr,pixel_err_pr, ndet, ne, ndet*ne, vx_min,vx_max,&
       bin_vx,eps,n,vy_min,vy_max,vz_min,vz_max,x_pr,intensity_pr,error_int_pr,m,vvy(1),vvz(1))

  !     Reduce size of output arrays x,intensity,error_int to useful data only  
  if (m .lt. n) then
     ! deal with x,intensity,error,number_pix now
     temp=mxCreatedoublematrix(1_i8b,m,0)
     temp_pr=>mxgetpr(temp)
     call reduce_output(m,n,x_pr,temp_pr)     
     call mxFreeMatrix(plhs(1))
     plhs(1)=temp
     temp=mxCreatedoublematrix(1_i8b,m,0)
     temp_pr=>mxgetpr(temp)
     call reduce_output(m,n,intensity_pr,temp_pr)
     call mxFreeMatrix(plhs(2))
     plhs(2)=temp
     temp=mxCreatedoublematrix(1_i8b,m,0)
     temp_pr=>mxgetpr(temp)
     call reduce_output(m,n,error_int_pr,temp_pr)
     call mxFreeMatrix(plhs(3))
     plhs(3)=temp
  end if

  plhs(4)       =mxCreatedoublematrix(1_i8b,1_i8b,0)
  plhs(5)       =mxCreatedoublematrix(1_i8b,1_i8b,0)

  call mxCopyReal8ToPtr(vvy,mxGetPr(plhs(4)),1_i8b)
  call mxCopyReal8ToPtr(vvz,mxGetPr(plhs(5)),1_i8b)
  return
end subroutine mexFunction
!
! ===============================================================================
! actual FORTRAN code for the cut3dxye_df algorithm
! distribute all data points into bins, then take average over each bin
! =============================================================================== 
subroutine cut3dxye_df(vx,vy,vz,pixel_int,pixel_err,ndet,ne,Npixels,vx_min,vx_max,bin_vx,eps,n,&
     vy_min,vy_max,vz_min,vz_max, x,intensity,error_int,m,vvy,vvz)
  ! declare input and output variables
  implicit NONE
  !     m = number of bins with data, 
  !     n = total number of bins	
  integer*8 m, n, ndet, ne, Npixels, bin_index(n), final_npixel,number_pix(n)
  real*8 vx(*), vy(*), vz(*), pixel_int(*), pixel_err(*), vx_min, vx_max, bin_vx, eps, vy_min,&
       vy_max, vz_min, vz_max,x(*), intensity(*),error_int(*), vvy, vvz
  ! declare local variables   
  integer*8 i, k, j, l
  ! initialize to zero the number of pixel per bin,x,intensity,error_int 
  do i=1,n
     number_pix(i)=0     ! integer
     x(i)         =0.0d0 ! double
     intensity(i) =0.0d0
     error_int(i) =0.0d0
  end do
  ! run through all pixels and if contributing then distribute then into bins
  vvy=0.0d0 ! will contain partial sum of vy values 
  vvz=0.0d0 ! will contain partial sum of vz values
  final_npixel=0   ! (integer) will contain final number of pixels going into the cut
  ! choose between normal binning along the vx axis (bin_vx >0) and binning along the energy axis only (bin_vx=0) 
  if (bin_vx .gt. eps) then  ! normal binning along the vx-axis 
     do k=1,Npixels
        if ((vx(k).ge.vx_min).and.(vx(k).lt.vx_max).and.(vy(k).ge.vy_min).and.(vy(k).le.vy_max).and.&
             (vz(k).ge.vz_min).and.(vz(k).le.vz_max).and. (pixel_int(k) .gt. -1d+30)) then ! also test if pixel is not masked  
           i=int((vx(k)-vx_min)/bin_vx+1.0d0)! index of bin along vx
           number_pix(i)=number_pix(i)+1 ! number of pixels so far in bin i
           final_npixel=final_npixel+1 ! increase total number of contributing pixels  
           x(i)         =x(i)+vx(k) ! sum vx values
           vvy          =vvy +vy(k) ! sum vy values
           vvz          =vvz +vz(k) ! sum vz values
           intensity(i) =intensity(i)+pixel_int(k) ! sum intensity values
           error_int(i) =error_int(i)+pixel_err(k)**2 ! sum errors squared
        end if
     end do    ! k=1,Npixels
  else     ! binning along the energy axis for each contributing detector
     do j=1,ndet
        do l=1,ne
           k=j+ndet*(l-1)   ! global index in the (ndet,ne) matrix 
           ! run energy index first, then detector index 
           if ((vx(k).ge.vx_min).and.(vx(k).lt.vx_max).and. (vy(k).ge.vy_min).and.(vy(k).le.vy_max).and.&
                (vz(k).ge.vz_min).and.(vz(k).le.vz_max).and. (pixel_int(k) .gt. -1d+30)) then ! also test if pixel is not masked  
              number_pix(j)=number_pix(j)+1 ! number of pixels so far in bin j
              final_npixel=final_npixel+1 ! increase total number of contributing pixels  
              x(j)         =x(j)+vx(k) ! sum vx values
              vvy          =vvy +vy(k) ! sum vy values
              vvz          =vvz +vz(k) ! sum vz values
              intensity(j) =intensity(j)+pixel_int(k) ! sum intensity values
              error_int(j) =error_int(j)+pixel_err(k)**2 ! sum errors squared
           end if
        end do! l=1,ne
     end do    ! j=1,ndet
  end if       ! bin_vx>eps
  m=0  ! will contain final number of bins with pixels in them 
  ! if no contributing pixels then return
  if (final_npixel .eq. 0) then 
     return
  end if
  ! take the average over each bin and count number of bins with data 	
  do i=1,n
     if (number_pix(i) .ge. 1) then
        m=m+1  ! move on to next bin with pixels
        bin_index(i) =m  ! former bin i becomes true bin m 
        number_pix(m)=number_pix(i)  
        x(m)         =x(i)/dfloat(number_pix(m)) ! average vx values
        intensity(m) =intensity(i)/dfloat(number_pix(m)) ! average intensity values
        error_int(m) =sqrt(error_int(i))/dfloat(number_pix(m)) ! average errors squared
     end if
  end do
  ! determine average of vy and vz values per cut
  vvy=vvy/dfloat(final_npixel)
  vvz=vvz/dfloat(final_npixel)
  !     x(1:m) vx values in bins, (m+1:end) discard
  !     intensity(1:m) intensity per bins, (m+1:end) discard 
  !     same with error_in(1:m)
  return
end  subroutine cut3dxye_df

subroutine reduce_output (m,n,full,reduced)
  integer*8::m,n
  real*8,intent(in)::full(n)
  real*8,intent(inout)::reduced(m)
  reduced(1:m)=full(1:m)
end subroutine reduce_output




