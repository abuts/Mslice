C==============================================================================================
C     >> mex slice_df_full.f
C     This is a MEX-file for MATLAB. Based on SLICE_DF.F au. R. Coldea
C
C	Original documentation:
C	--------------------------
C     to take a slice from a 3D data set of pixels with (vx,vy,vz) coordinates
C     take only pixels with coordinate  vz_min<vz<vz_max and plot intensity
C     (error calculated as well) onto a rectangular 2d grid in the
C     (vx,vy) plane [vx_min to vx_max] and [vy_min to vy_max]
C     10-Oct-2000 version for Digital Visual Fortran 6
C     use passing pointers in Fortran through the %VAL construct
C
C     19 May 2003   T.G. Perring:
C	-----------------------------
C     Modified version of slice_df that returns the information to write out a slice
C     in the format expected by TOBYFIT_V2
C
C    $Revision$  ($Date$)
C
C==============================================================================================
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
C-----------------------------------------------------------------------
      implicit NONE
C declares the pointer and integer sizes for current os and platform
#include "fintrf.h"
      character*(120)::REVISION=
C                1         2         3         4         5
     1 "Fortran Slice_full (slice_df_full.F)    "//
     2 "$Rev::      $ " //
     3 "($Date::                                              $)"
C       123456789012345678901234567890123456789012345678901234567890      

      mwpointer :: plhs(*), prhs(*)
	  integer*4 :: nrhs, nlhs,cpfg
      mwsize    :: nGridPoints

C declare local variables to deal with pointers to variables passed by/to MATLAB
      mwpointer vx_pr, vy_pr, vz_pr, pixel_int_pr, pixel_err_pr, grid_pr
      mwpointer xav_pr, yav_pr, intensity_pr, error_int_pr,
     c    number_pts_pr,detno_pr, eps_binno_pr, xpix_pr, ypix_pr,
     c    pix_int_pr, pix_err_pr
C declare calling functions
#ifdef OBSOLETE
      integer mxCreateFull
#endif      
      mwpointer:: mxGetPr,mxCreateCharMatrixFromStrings,
     C            mxCreateDoubleMatrix
      mwsize :: mxGetM, mxGetN
      mwsize :: mxIsNumeric,one

      mwsize :: n,m,number_pts_tot,ndet, ne,longOne;


C declare local operating variables of the interface funnction
      integer iflag
      real(8) grid(8), vx_min, vx_max, bin_vx,
     c    vy_min, vy_max, bin_vy, vz_min, vz_max,
     c    detno_dum, eps_binno_dum, xpix_dum, ypix_dum,
     c    pix_int_dum, pix_err_dum

C      ! Returns code SVN version
      if(nrhs==0 .AND. nlhs==1)then
        one=1
        plhs(1) = mxCreateCharMatrixFromStrings(one,REVISION)
        return
      end if
	  longOne = 1;

C     Check for proper number of MATLAB input and output arguments
      if (nrhs .ne. 6) then
         call mexErrMsgTxt
     c ('Six inputs (vx,vy,vz,pixel_int,pixel_err,grid) required.')
      elseif (nlhs .ne. 11) then
         call mexErrMsgTxt('Two outputs (intensity,err_int) required.')
      end if
C
C     Check to see if all inputs are numeric
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

C     Check sizes of input arguments
      ndet=mxGetM(prhs(1))
      ne  =mxGetN(prhs(1))
      if     ((mxGetM(prhs(2)).ne.ndet).or.
     +        (mxGetN(prhs(2)).ne.ne)) then
         call mexErrMsgTxt
     c('Size of input #2 does not mach that of input #1')
      elseif ((mxGetM(prhs(3)).ne.ndet).or.
     +        (mxGetN(prhs(3)).ne.ne)) then
         call mexErrMsgTxt
     c('Size of input #3 does not mach that of input #1')
      elseif ((mxGetM(prhs(4)).ne.ndet).or.
     +        (mxGetN(prhs(4)).ne.ne)) then
         call mexErrMsgTxt
     c('Size of input #4 does not mach that of input #1')
      elseif ((mxGetM(prhs(5)).ne.ndet).or.
     +        (mxGetN(prhs(5)).ne.ne)) then
         call mexErrMsgTxt
     c('Size of input #5 does not mach that of input #1')
      elseif ((mxGetM(prhs(6))*mxGetN(prhs(6))) .ne. 8) then
        call mexErrMsgTxt('Input #6 grid should have 8 elements.')
      end if
C
C     Get vx,vy,vz,pixel_int,pixel_err and grid parameters
      vx_pr=mxGetPr(prhs(1))
      vy_pr=mxGetPr(prhs(2))
      vz_pr=mxGetPr(prhs(3))
      pixel_int_pr=mxGetPr(prhs(4))
      pixel_err_pr=mxGetPr(prhs(5))
      grid_pr=mxGetPr(prhs(6))
C important below as on 64 bit machine const 8 is probably int and size of 4 but mwsize is longer (8?)      
      nGridPoints=8 
      call mxCopyPtrToReal8(grid_pr,grid,nGridPoints)
C
      vx_min=grid(1)
      vx_max=grid(2)
      bin_vx=grid(3)
      vy_min=grid(4)
      vy_max=grid(5)
      bin_vy=grid(6)
      vz_min=grid(7)
      vz_max=grid(8)
      n=int((vx_max+bin_vx-(vx_min-bin_vx/2.0d0))/bin_vx)
      m=int((vy_max+bin_vy-(vy_min-bin_vy/2.0d0))/bin_vy)
      
	cpfg=0
C
C     Create matrices for the return arguments
#ifdef OBSOLETE
      plhs(1)   = mxCreateFull(m,n,0)
      plhs(2)	= mxCreateFull(m,n,0)
      plhs(3)	= mxCreateFull(m,n,0)
      plhs(4)	= mxCreateFull(m,n,0)
      plhs(5)	= mxCreateFull(m,n,0)
#else
      plhs(1)   = mxCreateDoubleMatrix(m,n,cpfg)
      plhs(2)   = mxCreateDoubleMatrix(m,n,cpfg)
      plhs(3)   = mxCreateDoubleMatrix(m,n,cpfg)
      plhs(4)   = mxCreateDoubleMatrix(m,n,cpfg)
      plhs(5)   = mxCreateDoubleMatrix(m,n,cpfg)
#endif
      xav_pr        = mxGetPr(plhs(1))
      yav_pr        = mxGetPr(plhs(2))
      intensity_pr  = mxGetPr(plhs(3))
      error_int_pr  = mxGetPr(plhs(4))
      number_pts_pr = mxGetPr(plhs(5))

C     Call the computational subroutine slice_df
C	First time: fill the bins and get no. pixels for each bin
      iflag = 0
      call slice_df(%val(vx_pr),%val(vy_pr),%val(vz_pr),
     c     %val(pixel_int_pr),%val(pixel_err_pr),ndet,ne,
     c     vx_min-bin_vx/2.0d0,bin_vx,n,
     c     vy_min-bin_vy/2.0d0,bin_vy,m,
     c     vz_min,vz_max,iflag,
     c     %val(xav_pr),%val(yav_pr),
     c     %val(intensity_pr),%val(error_int_pr),
     c     %val(number_pts_pr),number_pts_tot,
     c     detno_dum, eps_binno_dum, xpix_dum, ypix_dum,
     c     pix_int_dum, pix_err_dum)
#ifdef OBSOLETE
      plhs(6) = mxCreateFull(number_pts_tot,1,0)
      plhs(7) = mxCreateFull(number_pts_tot,1,0)
      plhs(8) = mxCreateFull(number_pts_tot,1,0)
      plhs(9) = mxCreateFull(number_pts_tot,1,0)
      plhs(10)= mxCreateFull(number_pts_tot,1,0)
      plhs(11)= mxCreateFull(number_pts_tot,1,0)
#else
      plhs(6) = mxCreateDoubleMatrix(number_pts_tot,longOne,cpfg)
      plhs(7) = mxCreateDoubleMatrix(number_pts_tot,longOne,cpfg)
      plhs(8) = mxCreateDoubleMatrix(number_pts_tot,longOne,cpfg)
      plhs(9) = mxCreateDoubleMatrix(number_pts_tot,longOne,cpfg)
      plhs(10)= mxCreateDoubleMatrix(number_pts_tot,longOne,cpfg)
      plhs(11)= mxCreateDoubleMatrix(number_pts_tot,longOne,cpfg)
#endif
      detno_pr     = mxGetPr(plhs(6))
      eps_binno_pr = mxGetPr(plhs(7))
      xpix_pr      = mxGetPr(plhs(8))
      ypix_pr      = mxGetPr(plhs(9))
      pix_int_pr   = mxGetPr(plhs(10))
      pix_err_pr   = mxGetPr(plhs(11))
      iflag = 1
      call slice_df(%val(vx_pr),%val(vy_pr),%val(vz_pr),
     c     %val(pixel_int_pr),%val(pixel_err_pr),ndet,ne,
     c     vx_min-bin_vx/2.0d0,bin_vx,n,
     c     vy_min-bin_vy/2.0d0,bin_vy,m,
     c     vz_min,vz_max,iflag,
     c     %val(xav_pr),%val(yav_pr),
     c     %val(intensity_pr),%val(error_int_pr),
     c     %val(number_pts_pr),number_pts_tot,
     c     %val(detno_pr), %val(eps_binno_pr), %val(xpix_pr),
     c     %val(ypix_pr), %val(pix_int_pr), %val(pix_err_pr))

      return
      end
C!
! Format of slice file:
!   first line:
!     <nx = no. x bins>  <ny = no. y bins>  <x coord of centre of bin(1,1)>  <y coord of same>  <x bin width>  <y bin width>
!
!   then for each bin in the order (1,1)...(nx,1), (1,2)...(nx,2),  ... , (1,ny)...(nx,ny):
!      x(av)   y(av)   I(av)   err(I(av))   npix
!      det_no(1)      eps_centre(1)     d_eps(1)     x(1)     y(1)     I(1)     err(1)
!         .                 .              .           .        .        .        .
!      det_no(npix)   eps_centre(npix)  d_eps(npix)  x(npix)  y(npix)  I(npix)  err(npix)
C
C ===============================================================================
C actual FORTRAN code for the bin2dall_df algorithm
C distribute all data points into bins, then take average over each bin
C =============================================================================== 
      subroutine slice_df(vx,vy,vz,
     c     pixel_int,pixel_err,ndet,ne,
     c     vx_min,bin_vx,n,
     c     vy_min,bin_vy,m,vz_min,vz_max,iflag,
     c     xav,yav,intensity,error_int,number_pts,number_pts_tot,
     c     detno,eps_binno,xpix,ypix,pix_int,pix_err)
C declare input and output variables
      implicit NONE
C     m = number of rows, 
C     n = number of columns	
      mwsize :: n,m,number_pts_tot,ndet, ne;
      integer   iflag
      real(8) vx(*), vy(*), vz(*), pixel_int(*), pixel_err(*), 
     c                 vx_min, bin_vx, vy_min, bin_vy, vz_min, vz_max,
     c                 xav(*),yav(*),intensity(*),error_int(*),
     c                 number_pts(*),
     c                 detno(*),eps_binno(*),xpix(*),ypix(*),
     c                 pix_int(*),pix_err(*)
      real(8) vx_max, vy_max
C declare local variables   
      integer i, j, ij, k, pix_offset(m*n), idet, ie

C branch on IFLAG: IFLAG=0 then initial pass; IFLAG=1 then assume xav to 
C number_pnts have been filled correctly on the initial pass.
      if (iflag .eq. 0) then
C     initialize to zero the number of points and cumulative intensity
C     in each bin
        do i=1,m
          do j=1,n
            ij=i+m*(j-1)
            xav(ij) = 0.0d0
            yav(ij) = 0.0d0
            intensity(ij)=0.0d0
            error_int(ij)=0.0d0
            number_pts(ij)=0.0d0
          number_pts_tot=0
          end do
        end do
      else
C     get pointer array to starting locations of pixel information
        pix_offset(1) = 1
        if (m*n > 1) then
          do i = 2, m*n
          pix_offset(i) = pix_offset(i-1) + nint(number_pts(i-1))
        end do
        endif
      endif

C run through all pixels and if contributing then distribute then into bins
      vx_max=vx_min+n*bin_vx
      vy_max=vy_min+m*bin_vy 
      do k=1,ndet*ne
        if ((vx(k).ge.(vx_min)).and.(vx(k).lt.vx_max).and.
     c      (vy(k).ge.(vy_min)).and.(vy(k).lt.vy_max).and. 
     c      (vz(k).ge.(vz_min)).and.(vz(k).le.vz_max).and. 
     c      (pixel_int(k) .gt. -1d+30)) then
          i=int((vy(k)-vy_min)/bin_vy+1.0d0)
          j=int((vx(k)-vx_min)/bin_vx+1.0d0)
          ij=i+m*(j-1)
          if (iflag .eq. 0) then
          xav(ij) = xav(ij) + vx(k)
          yav(ij) = yav(ij) + vy(k)
          intensity(ij)=intensity(ij)+pixel_int(k)
          error_int(ij)=error_int(ij)+pixel_err(k)**2
          number_pts(ij)=number_pts(ij)+1.0d0
          number_pts_tot = number_pts_tot + 1
          else
          ie = (k-1)/ndet + 1 ! believe input array stores dets faster
          idet = k - (ie-1)*ndet
            detno(pix_offset(ij)) = idet
          eps_binno(pix_offset(ij)) = ie
          xpix(pix_offset(ij)) = vx(k)
          ypix(pix_offset(ij)) = vy(k)
          pix_int(pix_offset(ij)) = pixel_int(k)
          pix_err(pix_offset(ij)) = pixel_err(k)
          pix_offset(ij) = pix_offset(ij) + 1
        endif
       endif
      end do
C take the average over each bin
        if (iflag .eq. 0)then
        do i=1,m
          do j=1,n
            ij=i+m*(j-1)
            if (nint(number_pts(ij)) .ge. 1) then
              xav(ij) = xav(ij)/number_pts(ij)
              yav(ij) = yav(ij)/number_pts(ij)
              intensity(ij)=intensity(ij)/number_pts(ij)
              error_int(ij)=sqrt(error_int(ij))/number_pts(ij)
            else
              intensity(ij)=-1d+30
              error_int(ij)=0.0d0
            endif
          end do
        end do
        detno(1)     = 0.0d0
        eps_binno(1) = 0.0d0
        xpix(1)      = 0.0d0
        ypix(1)      = 0.0d0
        pix_int(1)   = 0.0d0
        pix_err(1)   = 0.0d0
      endif

      return
      end

