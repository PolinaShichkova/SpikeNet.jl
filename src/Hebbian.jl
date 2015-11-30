
using Parameters


@with_kw type PreQHebb{Float}
    θ::Float = 0.5
end

learn{Float}(::Type{PreQHebb{Float}}) = quote
    x = $Float(z_pre)
    z = $Float(z_post)
    dwplus = qplus * z * (x >= θ)
    dwmin = qmin * z * (x < θ)
    w = clamp(w + dwplus - dwmin * w, zero(w), one(w))
end

# =======================================================
# Rules for ff exc/inh
# =======================================================

@with_kw type QPreSubTernary{Float}
    qplus::Float = 1e-3
    qmin::Float = 1e-3
end

learn{Float}(::Type{QPreSubTernary{Float}}) = quote
    x = $Float(z_pre)
    y = $Float(I_post)
    dwplus = qplus * x * y * (z_post < θz_post)
    dwmin = qmin * x * y * (z_post >= θz_post)
    w = clamp(w + η_post * (dwplus - dwmin), zero(w), one(w))
end


@with_kw type QPostSubHebb{Float}
    θx::Float = 0.5
    qplus::Float = 1e-3
    qmin::Float = 1e-3
end

learn{Float}(::Type{QPostSubHebb{Float}}) = quote
    x = $Float(z_pre)
    z = $Float(z_post)
    dwplus = qplus * z * (x >= θx)
    dwmin = qmin * z * (x < θx)
    w = clamp(w + η_post * (dwplus - dwmin), zero(w), one(w))
end


@with_kw type QPostSubTernaryHebb{Float}
    θx::Float = 0.5
    qltp::Float = 1e-3
    qltd::Float = 1e-3
    qdec::Float = 1e-3
end

learn{Float}(::Type{QPostSubTernaryHebb{Float}}) = quote
    x = $Float(z_pre)
    y = $Float(I_post)

    dw_ltp = qltp * (x >= θx) * (z_post >= θz_post)
    dw_ltd = qltd * (x < θx) * (z_post >= θz_post)
    dw_dec = qdec * (x >= θx) * y * (z_post < θz_post)
    w = clamp(w + η_post * (dw_ltp - dw_ltd - dw_dec), zero(w), one(w))
end


# =======================================================
# Presynaptically-gated Hebb rule with subtractive decay
# =======================================================

@with_kw type PreGatedSubHebb{Float}
    θ::Float = 0.5
    μ::Float = 1e-3
end

learn{Float}(::Type{PreGatedSubHebb{Float}}) = quote
    x = $Float(z_pre)
    y = $Float(z_post)
    dw = x * (y - θ)
    w = clamp(w + μ * dw, zero(w), one(w))
end

# =========================================================
# Presynaptically-gated Hebb rule with multiplicative decay
# =========================================================

@with_kw type PreGatedMulHebb{Float}
    μ::Float = 1e-3
end

learn{Float}(::Type{PreGatedMulHebb{Float}}) = quote
    x = $Float(z_pre)
    y = $Float(z_post)
    dw = x * (y - w)
    w = clamp(w + μ * dw, zero(w), one(w))
end

# =========================================================

@with_kw type PreGatedMultQHebb{Float}
    θ::Float = 0.5
    q_min::Float = 1e-3
    q_plus::Float = 1e-3
    w_min::Float = 0.0
    w_max::Float = 1.0
end

learn{Float}(::Type{PreGatedMultQHebb{Float}}) = quote
    x = $Float(z_pre)
    y = $Float(z_post)
    dw_plus = q_plus * x * (y >= θ)
    dw_min = q_min * x * (y < θ)
    dw = dw_plus * (w_max - w) - dw_min * (w - w_min)
    w = clamp(w + dw, w_min, w_max)
end

# =========================================================

@with_kw type OmegaThresholdHebb{Float}
    θx::Float = 0.5
    θy::Float = 1.0
    θzplus::Float = 3.0
    θzmin::Float = 1.0
    q_ltp::Float = 1e-3
    q_ltd::Float = 1e-3
    q_dec::Float = 1e-3
end

learn{Float}(::Type{OmegaThresholdHebb{Float}}) = quote
    x = $Float(z_pre)
    y = I_post
    z = $Float(z_post)
    ltp = q_ltp * ((x >= θx) * (y >= θy) * (z >= θzplus))
    ltd = q_ltd * ((x >= θx) * (y >= θy) * (z >= θzmin) * (z < θzplus))
    dec = q_dec * ((x < θx) * (y >= θy))
    dw = ltp - (ltd + dec)
    w = clamp(w + dw, zero(w), one(w))
end

# =========================================================

@with_kw type OmegaThresholdEIHebb{Float}
    θx::Float = 0.5
    θy::Float = 1.0
    q_ltp::Float = 1e-3
    q_ltd::Float = 1e-3
    q_dec::Float = 2e-3
end

learn{Float}(::Type{OmegaThresholdEIHebb{Float}}) = quote
    x = $Float(z_pre)
    y = I_post
    z = $Float(z_post)
    ei = (Itot_post > zero(Itot_post))
    ltp = q_ltp * ((x >= θx) * (y >= θy) * (Itot_post > 0.0))
    ltd = q_ltd * ((x >= θx) * (y >= θy) * (Itot_post < 0.0))
    dec = q_dec * ((x < θx) * (y >= θy))
    dw = ltp - (ltd + dec)
    w = clamp(w + dw, zero(w), one(w))
end
