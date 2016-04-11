using GaussianProcesses
import ScikitLearnBase

d, n = 10, 20

x = 2π * rand(d, n)
y = Float64[sum(sin(x[:,i])) for i in 1:n]/d
mZero = MeanZero()
kern = SE(0.0,0.0)
gp = GP(x, y, mZero, kern)

# Function verifies that predictive mean at input observations
# are the same as the output observations
function test_pred_matches_obs(gp::GP)
    y_pred, sig = predict(gp, x)
    @test_approx_eq_eps maximum(abs(gp.y - y_pred)) 0.0 1e-4
end

test_pred_matches_obs(gp)

function sk_test_pred_matches_obs() # ScikitLearn interface test
    gp_sk = ScikitLearnBase.fit!(GP(), x', y)
    y_pred = ScikitLearnBase.predict(gp_sk, x')
    @test_approx_eq_eps maximum(abs(gp_sk.y - y_pred)) 0.0 1e-4
end

sk_test_pred_matches_obs()

# Modify kernel and update
gp.k.ℓ2 = 4.0
x_pred = 2π * rand(d, n)
GaussianProcesses.update_mll!(gp)
y_pred, sig = predict(gp, x_pred)
