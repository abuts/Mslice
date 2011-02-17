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
Mslice stores the last Libisis versions mslice seen activated in mslice_config structute,
stored in the configuration folder (see @config class) so, Mslice will try to
owerwrite the contents of ISIS utilites forlder if the version written there
is lower than current Libisis version or if the current mslice configuration 
has been deleted.
