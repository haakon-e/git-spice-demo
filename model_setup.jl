function model_setup(config)
    # Add input validation
    if !haskey(config, "dx") || config["dx"] <= 0
        error("Invalid dx: must be positive")
    end
    # Add comprehensive parameter checking
    required_keys = ["dx", "nx", "dt"]
    for key in required_keys
        if !haskey(config, key)
            error("Missing required parameter: $key")
        end
    end

    dx = config["dx"]
    u = zeros(length(config["nx"]))
    dudx = similar(u)
    # Initialize derivative field
    horizontal_derivative!(dudx, u, dx)
    return (; dx, u, dudx)
end
