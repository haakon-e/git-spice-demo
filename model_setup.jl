function model_setup(config)
    dx = config["dx"]
    u = zeros(length(config["nx"]))
    dudx = similar(u)
    # Initialize derivative field
    horizontal_derivative!(dudx, u, dx)
    return (; dx, u, dudx)
end
