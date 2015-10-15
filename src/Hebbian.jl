
using Parameters


@with_kw type PreGatedHebb
    θ::Float32 = 0.5
    μ::Float32 = 1e-3
end

learn(::Type{PreGatedHebb}) = quote
    dw = z_pre * (z_post - θ)
    w = clamp(w + μ * dw, zero(w), one(w))
end

@with_kw type PreGatedMultQHebb
    θ::Float32 = 0.5
    q_min::Float32 = 1e-3
    q_plus::Float32 = 1e-3
    w_min::Float32 = 0.0
    w_max::Float32 = 1.0
end

learn(::Type{PreGatedMultQHebb}) = quote
    x = Float32(z_pre)
    y = Float32(z_post)
    dw_plus = q_plus * x * (y >= θ)
    dw_min = q_min * x * (y < θ)
    w = w + dw_plus * (w_max - w) - dw_min * (w - w_min)
end

@with_kw type OmegaThresholdHebb
    θx::Float32 = 0.5
    θy::Float32 = 1.0
    θzplus::Float32 = 3.0
    θzmin::Float32 = 1.0
    q_ltp::Float32 = 1e-3
    q_ltd::Float32 = 1e-3
    q_dec::Float32 = 1e-3
end

b(x) = Float32(x)

learn(::Type{OmegaThresholdHebb}) = quote
    x = Float32(z_pre)
    y = I_post
    z = Float32(z_post)
    ltp = q_ltp * ((x >= θx) * (y >= θy) * (z >= θzplus))
    ltd = q_ltd * ((x >= θx) * (y >= θy) * (z >= θzmin) * (z < θzplus))
    dec = q_dec * ((x < θx) * (y >= θy))
    dw = ltp - (ltd + dec)
    w = clamp(w + dw, zero(w), one(w))
end
