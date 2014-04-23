function u = pgdSolver(A,b,u0,m_max,k_max)
    
    d_max = size(A,2);
    u = cell(d_max,1);
    
    for m=1:m_max
        % Initialization
        S = cellfun(@(v0) v0,u0,'UniformOutput',false);
        % Fixed point algo
        for k=1:k_max
            for d=1:d_max
                % Compute the matrix
                K = 0;
                tmp = cellfun(@(u,k) u'*k*u,repmat(S([1:d-1 d+1:end])',1,size(A,1))',A(:,[1:d-1 d+1:end]),'UniformOutput',false);
                for j=1:size(A,1)
                    K = K + prod([tmp{j,:}])*A{j,d};
                end
                
                % Compute the second member
                f = 0;
                tmp = cellfun(@(u,k) u'*k,repmat(S([1:d-1 d+1:end])',1,size(b,1))',b(:,[1:d-1 d+1:end]),'UniformOutput',false);
                for j=1:size(b,1)
                    f = f + prod([tmp{j,:}])*b{j,d};
                end
                
                if ~isempty(u{1})
                    tmp = cellfun(@(s,k,u) s'*k*u,repmat(S([1:d-1 d+1:end])',1,size(A,1))',A(:,[1:d-1 d+1:end]),repmat(u([1:d-1 d+1:end]),1,size(A,1))','UniformOutput',false);
                    for j=1:size(A,1)
                        for l=1:size(u{1},2)
                            f = f - prod(cellfun(@(u) u(l),tmp(j,:)))*A{j,d}*u{d}(:,l);
                        end
                    end
                end
                
                % Solve it
                S{d}(logical(u0{d})) = K(logical(u0{d}),logical(u0{d}))\f(logical(u0{d}));
                
                % Norm it if it isn't the last one
                if (d ~= 1 && norm(S{d}) > 10^(-10))
                    S{d} = S{d}./norm(S{d});
                end
            end
        end
        
        % Add the new modes
        for d=1:d_max
            u{d} = [u{d} S{d}];
        end
        disp('New mode added');
    end
end