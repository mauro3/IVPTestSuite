# This is a sample setup for a test case with an explicit QDE/DAE
# function.  Fill in the ...

# First , document the test case here!

export plei

# create an instance of TestCaseExplicit by filling in the ...:
plei = let
    tcname = :plei ::Symbol # name should be same as variable name (except for upper/lower case)

    T = Float64 # the datatype used, probably Float64
    Tarr = [Matrix, SparseMatrixCSC][2] # the container datatype used
                                        # for the Jacobian and mass
                                        # matrix, probably Matrix
                                        # (default) or
                                        # SparseMatrixCSC.
    N = 7
    dof = 4N::Int # degrees of freedom
    dae = 0 ::Int  # index of DAE, ==0 for ODE
    # stiffness of system, one of the three constants
    stiffness = [nonstiff, mildlystiff, stiff][1]


    ## the problem function
    function fn!(t::T,y::Vector{T},dydt::Vector{T})
        # The ode function dydt = f(t,y) modifying dydt in-place.
        # Note that all indices of dydt need to be written!

        x1,x2,x3,x4,x5,x6,x7,y1,y2,y3,y4,y5,y6,y7,x1′,x2′,x3′,x4′,x5′,x6′,x7′,y1′,y2′,y3′,y4′,y5′,y6′,y7′ = y[:]
        #parameters
        r = zeros(Float64,7,7)
        x″= zeros(Float64,7,7)
        y″= zeros(Float64,7,7)
        println(r)
        for i = 1:N
          for j =1:N
            setindex!(r,((y[i] -y[j])^2 + (y[i+N] -y[j+N])^2)^(3/2),i,j)
          end
        end

        for i = 1:N
          for j =1:N
            x″[i] =+ j*(y[j] - y[i])/r[i,j]  #j factor is mass of particles
            y″[i] =+ j*(y[j+N] - y[i+N])/r[i,j]
          end
        end
        dydt[:] = [x1′,x2′,x3′,x4′,x5′,x6′,x7′,y1′,y2′,y3′,y4′,y5′,y6′,y7′,
                  x″[1],x″[2],x″[3],x″[4],x″[5],x″[6],x″[7],y″[1],y″[2],y″[3],y″[4],y″[5],y″[6],y″[7]]
        return nothing
    end
    # initializes storage for y:
    fn!( ; T_::Type=T, dof_=dof) = zeros(T_,dof_)

    # NOTE, using keyword arguments more intuitively like:
    # fn!( ; T::Type=T, dof=dof) = zeros(T,dof)
    # does not work: https://github.com/JuliaLang/julia/issues/9948

    jac! = nothing
    mass! = nothing

    ic =  T[3, 3, -1, -3, 2, -2, 2,  #x(0)
            3, -3, 2, 0, 0, -4, 4,    #y(0)
            0, 0, 0, 0, 0, 1.75, -1.5, #x'(0)
            0, 0, 0, -1.25, 1, 0, 0]  #y'(0)
              # vector of initial conditions
    tspan = T[0, 3] # integration interval

    refsol = T[0.3706139143970502,3.237284092057233,-3.222559032418324,0.6597091455775310, 0.3425581707156584, 1.562172101400631,-0.7003092922212495,
    -3.943437585517392,-3.271380973972550, 5.225081843456543, -2.590612434977470, 1.198213693392275, -2429682344935824,1.091449240428980,
    3.417003806314313, 1.354584501625501, -2.590065597810775, 2.025053734714242, -1.155815100160448, -0.8072988170223021, 0.5952396354208710,
    -3.741244961234010, 0.3773459685750630, 0.9386858869551073, 0.3667922227200571, -0.3474046353808490, 2.344915448180937, -1.947020434263292]
              # reference solution at tspan[2]

    refsolinds = trues(dof)   # if refsol does not contain all indices
                              # then specify which indices of the
                              # solution are to be compared to refsol

    scd_absinds = Int[]       # set where refsol is very small or
                              # zero. To avoid it dominating the
                              # relative error

    tc = TestCaseExplicit{tcname, T, Tarr}(
                             stiffness,
                             dae,
                             dof,
                             fn!,
                             jac!,
                             mass!,
                             ic,
                             tspan,
                             refsol,
                             refsolinds,
                             scd_absinds)

    # put into the right buckets
    tc_all[tcname] = tc
    tc_nonstiff[tcname] = tc
    # Note that the return-result of the last statement of the let
    # block needs to be tc!
    tc
end
