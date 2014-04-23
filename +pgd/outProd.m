function y = outProd(u, varargin)
% OUTPROD compute the outer tensor product y = u*varargin
%
% @param u : a matrix
% @param varargin : a infinity of matrix
%
% @return y : a matrix in N-dimension
%
    if nargin > 0
        my_ndims = @(x)(isvector(x) + ~isvector(x) * ndims(x));
        y = u;
        if nargin > 1
            for k = 1:numel(varargin)
                v = varargin{k};
                v_t = permute(v, circshift(1:(my_ndims(y) + my_ndims(v)),[0, my_ndims(y)]));
                y = bsxfun(@times, y, v_t);
            end
        end
    else
        y = 1;
    end
end
