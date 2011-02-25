function recoil
data=fromwindow;
h=findobj('name','MSlice : Display');
if (length(h) > 1)
    disp('More than one MSlice Display window open,')
    disp('please click on the one you want to display the recoil line')
    k=waitforbuttonpress;
    h=gcf;
end
if isempty(data)
    disp('No data in window to extract')
return
end
val=get(findobj('tag','recoil_mass'),'string');
if isempty(val)
    m=input('Enter atomic mass of recoil atom ');
else
    m=str2num(val);
end


tre=isnan(m);
if (tre==0);
ei=data.efixed;
thimax=2.44;
q2=(2.0*ei-2.0*cos(thimax)*((ei*ei)^0.5))/2.072;
qmax=sqrt(q2);
q=zeros(length(data.S));
dq=qmax/length(data.S);
%q=0:dq:qmax;
q1=data.v(:,:,1);
q2=data.vb(:,:,1);
%e=zeros(length(data.S));

e1=2.072.*q1.^2./m;
e2=2.072.*q2.^2./m;

whos
data
%data.vb(:,:,1)=data.vb(:,:,1)-e;
data.vb(:,:,2)=(data.vb(:,:,2)-e2)./((2.072.*q2)./(m/2));
%data.vb(:,:,3)=data.vb(:,:,3)-e;
data.vb(:,:,4)=(data.vb(:,:,4)-e2)./((2.072.*q2)./(m/2));

data.v(:,:,2)=(data.v(:,:,2)-e1)./((2.072.*q1)./(m/2));

towindow(data)
%plot(q(:,1),e(:,1));



else
disp('Value entered must be a number')
end
return

