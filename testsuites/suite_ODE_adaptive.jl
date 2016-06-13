resODE = Dict{Symbol,Dict}()
const S = Solvers

for (n,tc) in totest
    res = Dict{Solver,Any}()
    for solver in S.ODEsolvers
        if isapplicable(solver, tc) && isadaptive(solver)
            res[solver] = run_ode_testsuite(suite)
        end
    end
    resODE[n] = res
end
