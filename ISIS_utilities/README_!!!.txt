This folder used to keep general Matlab utilites which were common with Libisis. 
Currently the utilites here are mainly related to old style hdf rotuines in Mslice 
and generic configuration routines (may be equal to Herbert)

The hdf files may clash with Libisis but Herbert uses different apporach. 
the configuration may clash with Herbert


Obsolete===>
This folder intended to keep the general matlab utilites which are not related to libisis or neutron experiments but are used by all ISIS packages
It is used primary during packages installation

The purpose of this folder is to decrease the interdependence between the packages, as each package which is installed separately would need a copy of this folder.

!!!!>>>>>>> You may find this folder in Mslice directory. <<<<  !!!!
!!!!                      BEWARE                                !!!!
!!!!  it contents can be owerwritten by Mslice without warning  !!!!
!!!!>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<!!!!
if Mslice finds libisis initiated during its startup, and the version of the
Libisis is higher, that the one, Mslice have seen before*, the contents of
this folder in Mslice directory will be owerwritten by the contents of
the correspondent Libisis folder

*before
Mslice stores the last Libisis versions it met in mslice_config structute,
stored in the configuration folder (see @config class) so, Mslice will try to
owerwriet the contents of ISIS utilites forlder if the version written there
is lower than current Libisis version or if the current configuration has been
deleted.
