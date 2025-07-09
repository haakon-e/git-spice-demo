function model_run(config)
    dx, u, dudx = model_setup(config)
    dt = config["dt"]
    for i in 1:config["nt"]
        @. u += u * dudx * dt
    end
    return u
end
