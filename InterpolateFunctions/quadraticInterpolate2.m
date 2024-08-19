function [outputArg1, outputArg2] = quadraticInterpolate2(A,Z)
%Interpolate data points with 2 independent variables and 1 response variable for a quadratic model
%   Takes 2 matrices as arguments:
%   A : N x 2 matrix containing, at each row, values for the independent variables in the
%       data points
%   Z : N x 1 matrix containing, at each row, a value for the response
%       variable
%   Returns [B, R2] where B is an array containig the parameters for the model:
%   z(x,y) = B(1) + B(2)*x + B(3)*y + B(4)*x*y + B(5)*(x.^2) + B(6)*(y^2)
%   and R2 the determination coefficient of the model

X = ones(length(A),1);
Ax = A(:,1);  % column matrix containing all values for x
Ay = A(:,2);  % column matrix containing all values for y
Axy = Ax.*Ay; % column matrix containing all values for xy 
Ax2 = Ax.^2;  % column matrix containing all values for x^2
Ay2 = Ay.^2;  % column matrix containing all values for y^2
X = [X Ax Ay Axy Ax2 Ay2];

B = (inv(X' * X))*(X')*Z;

z = @(x, y)B(1) + B(2)*x + B(3)*y + B(4)*(x.*y) + B(5)*(x.^2) + B(6)*(y.^2);

zm = sum(Z)/length(Z);
Zmodel = z(Ax, Ay);
R2 = (sum((Zmodel - zm).^2))/(sum((Z - zm).^2));

outputArg1 = B;
outputArg2 = R2;
end