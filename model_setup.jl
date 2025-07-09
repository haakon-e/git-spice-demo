function model_setup(config)
    # Add input validation
    if !haskey(config, "dx") || config["dx"] <= 0
        error("Invalid dx: must be positive")
    end

    dx = config["dx"]
    u = zeros(length(config["nx"]))
    dudx = similar(u)
    # Initialize derivative field
    horizontal_derivative!(dudx, u, dx)
    return (; dx, u, dudx)
end
