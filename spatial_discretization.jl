"""
    horizontal_derivative!(dudx, u, dx)

Computes the horizontal derivative of a 1D array `u` with spacing `dx`.
"""
function horizontal_derivative!(dudx, u, dx)
    n = length(u)
    for i in 1:n
        if i == 1
            dudx[i] = (u[i+1] - u[i]) / dx
        elseif i == n
            dudx[i] = (u[i] - u[i-1]) / dx
        else
            dudx[i] = (u[i+1] - u[i-1]) / (2 * dx)
        end
    end
    nothing
end
