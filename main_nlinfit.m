clearvars;
close all;
clc;

x = 1:5;
y = 2*x + normrnd(0, 1, size(x)) + 5;
modelfun = @(b, x) b(1)*x + b(2);
beta0 = [0, 0];
%beta = nlinfit(x, y, modelfun, beta0);
mdl = fitnlm(x, y, modelfun, beta0);
beta = mdl.Coefficients.Estimate;
scatter(x, y);
hold on;
plot(x, modelfun(beta, x));