%coeff array: a0;a1;a2;a3
% %3c123:
% a_array = [1.8077;-0.8018;-0.1157;0];
% %3c196:
%  a_array = [1.2969;-0.8690;-0.1788;0.0305];
% %3c286:
%  a_array = [1.2515;-0.4605;-0.1715;0.0336];
% %3c295:
 a_array = [1.4866;-0.7871;-0.3440;0.0749];

freq_array = 0.3275:1:48.565;
freq_array = freq_array';

flux_array = zeros(size(freq_array,1),1);
for i = 1:size(freq_array,1)
    freq = freq_array(i);
    log_flux = a_array(1) + a_array(2)*log10(freq) + a_array(3)*(log10(freq))^2 + a_array(4)*(log10(freq))^3;
    flux_array(i) = log_flux;
end

myfittype=fittype('a0 + a1*log10(x) + a2*log10(x)^2',...
'dependent','y', 'independent','x','coefficients', {'a0','a1','a2'});
myfit=fit(freq_array*1000,flux_array,myfittype,'StartPoint',[1 1 1])

%original
plot(freq_array*1000,  10.^flux_array);
hold on
%new fit (input MHz and only 3 coeff.):
%3c123:
       a0 =       3.172;
       a1 =     -0.1076;
       a2 =     -0.1157;
for i = 1:size(freq_array,1)
    freq = freq_array(i)*1000;
    log_flux = a0 + a1*log10(freq) + a2*(log10(freq))^2;
    flux_array(i) = log_flux;
end
plot(freq_array*1000,  10.^flux_array);
