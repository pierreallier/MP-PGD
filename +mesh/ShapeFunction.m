classdef ShapeFunction
    %ShapeFunction Hold the expression of a shape function.
	properties
        dim = 0;
        exp_handle;
        diff_handle;
        jac_handle;
    end
   
	methods
        function this = ShapeFunction(dim, exp, diff)
            %ShapeFunction constructor Create the shape function based on
            %the expression given in a handle of x and the 1st order
            %derivative diff given in a handle of x
            this.dim = dim;
            this.exp_handle = exp;
            this.diff_handle = diff;
        end
        
        function this = setJacobian(this, jac_handle)
            this.jac_handle = jac_handle;
        end
        
        function val = localDiff(this, val)
            val = this.diff_handle(val);
        end
        
        function val = globalDiff(this, val)
            val = this.jac_handle(val)\this.diff_handle(val)';
        end
        
        function val = exp(this, val)
            val = this.exp_handle(val);
        end
    end
end