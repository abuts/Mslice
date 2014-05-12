function [ix,iy,iz] = get3DDirection(iz)
% function returns complete set of directions given the direction, the cut
% should be orthogonal to

if iz==1,
    ix=2;
    iy=3;
elseif iz==2,
    ix=3;
    iy=1;
elseif iz==3,
    ix=1;
    iy=2;
else
    error('MSLICE:get3DDirection','Cannot perform slice perpendicular to axis number %s',num2str(iz))
end

