function y=multimidfilter(x,m,order)

if nargin < 3
    order = 5; %5th order median filtering is used by default
end

a=x;
for k=1 : m
    b=medfilt1(a, order); 
    a=b;
end
y=b;
