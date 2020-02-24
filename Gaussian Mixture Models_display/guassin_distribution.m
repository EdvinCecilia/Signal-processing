X= 1*randn(1000,1) ;    
Y= 3*X+5*randn(1000,1) ;
X1 = 1*randn(1000,1)+10;
Y1 = 4*X+3*randn(1000,1) ;
X3= 3*randn(1000,1) ;    
Y3= 1*X+1*randn(1000,1)+15 ;
plot(X,Y,'.')
hold on;
plot(X1,Y1,'.')
hold on;
plot(X3,Y3,'.') 