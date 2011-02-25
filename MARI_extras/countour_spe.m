function countour_spe(data)

q=data.v(:,:,1);
e=data.v(:,:,2);


data=smooth_spe(data,5);
%find the q and e region of interest
%[i,j]=find(q>qmin & q<qmax & e>emin & e <emax);
%now reduce the dataset to that size, intensity errors Q and E
% data2=(data.S([min(i):max(i)],[min(j):max(j)]));
% q2=(q([min(i):max(i)],[min(j):max(j)]));
% e2=(e([min(i):max(i)],[min(j):max(j)]));
% whos
%figure
[cont]=ind2sub(size(data.S),data.S>.1 & data.S<40 );
%surf(q,e,(data.S.*cont));

%spinmap(10)
figure
 
s=.1 ;delstep=1;
for i =1:30;
[cont]=ind2sub(size(data.S),data.S>s & data.S<s+delstep );
contour(q,e,(data.S.*cont),1);
hold all

s=s+5;
end

spinmap(10)