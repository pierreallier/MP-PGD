function [xg,wg] = gaussPoints(elem)
    if isa(elem, 'mesh.Tress2')
        wg = [1 1];
        xg = sqrt(3/9)*[-1;1];
    elseif isa(elem, 'mesh.Triangle3')
        wg = [1/6 1/6 1/6];
        xg = 1/6*[1 1;4 1;1 4];
    else
        warning('gaussPoint:BadInput','Unknown Element - skipped');
    end
end